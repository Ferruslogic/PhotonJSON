script "PhotonJSON"
--------------------------------------------------------------------------------------------------------------------------
#  Name: PhotonJSON
#  Type: Library
#  Version: v1.1.0
#  Author: FerrusLogic
#  Code repository: https://github.com/Ferruslogic/PhotonJSON/
#  Web: https://ferruslogic.com/
#  License: https://opensource.org/licenses/MIT
#  Description: LiveCode script library for working with JSON, written in livecode-script and without the use of external.
#  Note: PhotonJSON follows JSON's standards presented in https://www.json.org/json-en.html
#  Date: Nov 2020
#  Last Update: March 2021
--------------------------------------------------------------------------------------------------------------------------
#  declare script local variables
local sIndentSize

# declare constants
constant kVersion = "v1.1.0"

# The current version of the library.
getProp cVersion
    return kVersion
end cVersion

-----------------------------------------------------------------------------------------
--- These functions are for compatibility with projects that use mergJSON ---
-----------------------------------------------------------------------------------------
--function jsonToArray pJSON
--    return JSONParser(pJSON,true)
--end jsonToArray

--function arrayToJson pArray, pForceRootType, pPretty
--    return JSONStringify(pArray,pPretty,true)
--end arrayToJson

----------------------------------------------------------------------------------------
--- These functions are for compatibility with projects that use FASTJSON ---
----------------------------------------------------------------------------------------
--function arrayFromJson pJson
--    return JSONParser(pJSON,true)
--end arrayFromJson

--function jsonFromArray pArray, pForceRootType, pPretty
--    return JSONStringify(pArray,pPretty,true)
--end jsonFromArray

------------------------------------------------------------------------------------------
------------------------------ CODE OF LIBRARY -------------------------------------
-----------------------------------------------------------------------------------------

# validateJSON: Validate if a string is a valid JSON.
# Parameter: The JSON to evaluate. (String)
# returns: A boolean. (Boolean)
function validateJSON pJsonString
    local tCont = 0, tTokenCont = 0, tSplit
    if _jsonToUtf8( pJsonString ) is true then return pJsonString
    # escaped quotes < \" > and reverse-solidus < \\ > will confuse the tokenizer
    # so we replace them with "\u0022" and "\u005C" which we'll unescape
    # with all the other unescapes when we parse
    if "\\" is in pJsonString then replace "\\" with "\u005C" in pJsonString
    if (backSlash & quote) is in pJsonString then replace (backSlash & quote) with "\u0022" in pJsonString
    if "\/" is in pJsonString then replace "\/" with "/" in pJsonString

    repeat for each token tToken in pJsonString
        add 1 to tTokenCont
        switch tToken
            case "{"
            case "["
                add 1 to tCont
                break
            case "}"
            case "]"
                subtract 1 from tCont
                break
            case "+"
                put the token (tTokenCont - 1) to (tTokenCont + 1) of pJsonString into tSplit
                split tSplit by quote
                if tSplit[2] is not "+" then
                    return false
                end if
                break
        end switch

        if tToken begins with "0" and tToken is not 0 then
            put the token (tTokenCont - 1) to (tTokenCont + 1) of pJsonString into tSplit
            split tSplit by quote
            if tSplit[2] is not tToken then
                return false
            end if
        end if
    end repeat

    return (tCont is 0 )
end validateJSON


# beautifyJSON: JSON string formatted in a more visually pleasing way.
# Parameter:
# 1: JSON string (String)
# 2: Numbers of spaces in Indent (Integer)
# returns: JSON string (String)
function beautifyJSON pJsonString, pIndentSize
    if _jsonToUtf8( pJsonString ) is true then return pJsonString
    if pIndentSize is an integer then put pIndentSize into sIndentSize
    else put 2 into sIndentSize
    replace tab with empty in pJsonString
    replace cr with empty in pJsonString
    return __JsonPrettyCompact(pJsonString, pIndentSize)
end beautifyJSON


# minifyJSON: Remove unnecessary spaces from JSON string.
# Parameter:
# 1: JSON string (String)
# 2: if it is treated as Unicode (Boolean)
# returns: JSON string (String)
function minifyJSON pJsonString
    local tFormatted,  tPrevToken = "", tIndex  = 0,  tOpenClose = "",  tItems  = "", tHyphenMinus = false

    if _jsonToUtf8( pJsonString ) is true then return pJsonString

    # escaped quotes < \" > and reverse-solidus < \\ > will confuse the tokenizer
    # so we replace them with "\u0022" and "\u005C" which we'll unescape
    # with all the other unescapes when we parse
    if "\\" is in pJsonString then replace "\\" with "\u005C" in pJsonString
    if (backSlash & quote) is in pJsonString then replace (backSlash & quote) with "\u0022" in pJsonString
    if "\/" is in pJsonString then replace "\/" with "/" in pJsonString

    repeat for each token tToken in pJsonString

        switch tToken

            case "{"
            case "["
            case "}"
            case "]"
            case ":"
            case comma
                put tToken  after tFormatted
                break

            case "-"
                put true into tHyphenMinus
                next repeat
                break

            default
                if tHyphenMinus then
                    put "-" & tToken into tToken
                    put false into tHyphenMinus
                end if
                replace "\u005C" with "\" in tToken
                replace "\u0022"  with  quote in tToken
                put _JsonString( tToken ) after tFormatted
        end switch

        put tToken into tPrevToken
    end repeat

    put textDecode( tFormatted, "UTF8") into tFormatted

    return tFormatted
end minifyJSON

# This flag is used to determine if the function is being called by itself.
# So you don't have to repeat some operations and only do them when you finish building the JSON.
local sRecursionCounter = 0

# JSONStringify: Gets the JSON string from an LC Array.
# Parameter:
# 1: LC Array (Array)
# 2:
# 3: if JSON is formatted nice (Boolean)
# returns: JSON string (String)
function JSONStringify pArray, pForceRootType, pPretty
    local tJsonString = "[",  tIsNumeric = true, tKeys = "", tEndChar = "]"

    add 1 to sRecursionCounter
    if pArray is not an array then return "{}"
    set the caseSensitive to true

    # The array's keys are all *numerical*, so the root element will be a JSON *array*
    repeat for each key k in pArray
        if k is not an integer then
            put false into tIsNumeric
            put "{" into tJsonString
            put "}" into tEndChar
            exit repeat
        end if
    end repeat


    # The values of the JSON keys will be formatted to their type.
    if pForceRootType is "string" or pPretty is true then

        repeat for each  key k in pArray

            if pArray[ k ] is an array then

                if  tIsNumeric  then
                    put  (JSONStringify ( pArray[ k ] , "string", pPretty))  & comma after tJsonString
                    next repeat
                else

                    put  _JsonString( k )  & ": " &  (JSONStringify( pArray[ k ], "string", pPretty)) & comma after tJsonString
                    next repeat
                end if

            else  if  tIsNumeric  then
                put  _JsonString( pArray[ k ] )   & comma after tJsonString
                next repeat

            else
                put _JsonString( k )  & ": " & _JsonString( pArray[ k ] ) & comma after tJsonString
                next repeat

            end if
        end repeat

    else

        repeat for each  key k in pArray
            if pArray[ k ] is an array then

                if  tIsNumeric  then
                    put  (JSONStringify ( pArray[ k ] )) & comma after tJsonString
                    next repeat

                else
                    put  _JsonString( k )  & ": " &  (JSONStringify( pArray[ k ] )) & comma after tJsonString
                    next repeat

                end if

            else  if  tIsNumeric  then
                put   _JsonValue( pArray[ k ] )   & comma after tJsonString
                next repeat

            else
                put _JsonString( k )  & ": " &  _JsonValue( pArray[ k ] ) & comma after tJsonString
                next repeat

            end if
        end repeat

    end if

    put tEndChar into the char - 1 of tJsonString
    subtract 1 from sRecursionCounter

    if sRecursionCounter is 0 then
        set the caseSensitive to false

        if numToChar(8) is in tJsonString then replace numToChar(8) with "\b" in tJsonString
        if numToChar(9) is in tJsonString then replace numToChar(9) with "\t" in tJsonString
        if numToChar(10) is in tJsonString then replace numToChar(10) with "\n" in tJsonString
        if numToChar(12) is in tJsonString then replace numToChar(12) with "\f" in tJsonString
        if numToChar(13) is in tJsonString then replace numToChar(13) with "\r" in tJsonString
        # Pretty
        if pPretty  then return _JsonPrettyCompact(tJsonString, 2, pForceRootType)
    end if

    return tJsonString
end JSONStringify

# JSONParser: Gets the LC Array of a JSON string
# Parameter:
# 1: JSON string (String)
# returns: LC Array (Array)
function JSONParser pJsonString
    local tKeyNameOrValue = 0, tArrayKeysPath , tNumKeys = 0 ,tOpenJArray, tResultArray, tHyphenMinus
    local tOldToken, tObjEmpty = ""

    if pJsonString is empty then return empty
    if _jsonToUtf8( pJsonString ) is true then return pJsonString
    # escaped quotes < \" > and reverse-solidus < \\ > will confuse the tokenizer
    # so we replace them with "\u0022" and "\u005C" which we'll unescape
    # with all the other unescapes when we parse
    replace "\\" with "\u005C" in pJsonString
    replace (backSlash & quote) with "\u0022" in pJsonString

    repeat for each token tToken in pJsonString
        if tNumKeys < 0  then put 0 into tNumKeys

        switch tToken
            case "{"
                put 0 into tKeyNameOrValue
                put tToken  into tOldToken

                next repeat
                break

            case "["
                add 1 to tNumKeys
                put 1 into tKeyNameOrValue
                put 1 into tArrayKeysPath[tNumKeys]
                put tNumKeys into tOpenJArray[tNumKeys]
                put tToken  into tOldToken
                next repeat
                break

            case "}"

                # Fix bug when JSON has empty objects
                if tOldToken is "{" then
                    _builderArray tObjEmpty, tArrayKeysPath, tResultArray, tNumKeys
                    put tToken into tOldToken
                    next repeat
                end if


                delete variable tArrayKeysPath[tNumKeys]
                subtract 1 from tNumKeys

                put tToken  into tOldToken
                next repeat
                break

            case comma
                if tOpenJArray[ tNumKeys ] <> empty then
                    if tArrayKeysPath[tNumKeys ] is an integer then
                        add 1 to tArrayKeysPath[tNumKeys]
                        put 1 into tKeyNameOrValue
                    end if
                else
                    delete variable tArrayKeysPath[tNumKeys]
                    subtract 1 from tNumKeys
                    put 0 into tKeyNameOrValue
                end if

                put tToken  into tOldToken
                next repeat
                break
            case colon

                put 1 into tKeyNameOrValue
                put tToken  into tOldToken
                next repeat
                break
            case "]"
                delete variable tArrayKeysPath[tNumKeys]
                delete variable tOpenJArray[tNumKeys]
                subtract 1 from tNumKeys
                put 0 into tKeyNameOrValue

                # Fix bug when JSON has empty array
                if tOldToken is "[" then
                    _builderArray tObjEmpty, tArrayKeysPath, tResultArray, tNumKeys
                    put tToken into tOldToken
                end if

                put tToken  into tOldToken
                next repeat
                break
            case "-"
                put true into tHyphenMinus
                put tToken  into tOldToken
                next repeat
                break
        end switch

        if backslash is in tToken then
            if "\n" is in tToken then replace "\n" with numToChar(10) in tToken
            if "\r" is in tToken then replace "\r" with numToChar(13) in tToken
            if "\t" is in tToken then replace "\t" with numToChar(9) in tToken
            if "\/" is in tToken then replace "\/" with "/" in tToken
            if "\f" is in tToken then replace "\f" with numToChar(12) in tToken
            if "\b" is in tToken then replace "\b" with numToChar(8) in tToken
            if "\u0022" is in tToken then replace "\u0022" with quote in tToken
            if "\u005C" is in tToken then replace "\u005C" with "\" in tToken
            if "\u" is in tToken then put _unicodeEscapes(tToken) into tToken
        end if

        put _utf8decode(tToken) into tToken

        put empty  into tOldToken

        if tKeyNameOrValue = 1 then
            if "null" is tToken then
                put empty into tToken
            else if tHyphenMinus then
                put "-" & tToken into tToken
                put false into tHyphenMinus
            end if

            _builderArray tToken, tArrayKeysPath, tResultArray, tNumKeys
        else if tKeyNameOrValue = 0 then
            add 1 to tNumKeys
            put tToken into tArrayKeysPath[tNumKeys]
        end if
    end repeat

    return tResultArray
end JSONParser

private function _JsonString @pValue
    if pValue is not an ascii string then put _utf8encode(pValue) into pValue

    # So these characters escape in case they are there.
    # https://www.json.org/img/string.png
    # any other value is processed as a string.
    # JSON strings require that certain characters be 'escaped' with a backslash:
    # This makes the processing a bit slower. But it is necessary for it to comply with the ECMA-404 standard
    if "\" is in pValue then replace "\" with "\\" in pValue
    if quote is in pValue then replace quote with "\" & quote in pValue

    return quote &  pValue  & quote
end _JsonString


private function  _JsonValue @pValue
    switch pValue
        case "true"
            return "true"
            break
        case "false"
            return "false"
            break
        case ""
            return "null"
            break
        case "null"
            return "null"
            break
        default
            if pValue is a number then
                if not (char 1 of pValue is 0 and char 2 of pValue is not "." and the length of pValue is not 1 or char 1 of pValue is not in "-0123456789") then
                    return pValue
                end if
            end if
            return _JsonString( pValue )
    end switch
end  _JsonValue



private command _builderArray @pValue, @pListKeys, @pArray, @pNumKeys
    local tArray

    # Adding caseSensitive  when creating key names, to avoid overwriting keys such as the following:
    # A100 = "50", a100 = 33
    set the caseSensitive to true

    switch pNumKeys
        case 0
            break
        case 1
            put pValue into pArray[pListKeys[1]]
            break
        case 2
            put pValue into pArray[ pListKeys[1] ][ pListKeys[2] ]
            break
        case 3
            put pValue into pArray[ pListKeys[1] ][ pListKeys[2] ][ pListKeys[3] ]
            break
        case 4
            put pValue into pArray[ pListKeys[1] ][ pListKeys[2] ][ pListKeys[3] ][ pListKeys[4] ]
            break
        case 5
            put pValue into pArray[ pListKeys[1] ][ pListKeys[2] ][ pListKeys[3] ][ pListKeys[4] ][ pListKeys[5] ]
            break
        case 6
            put pValue into pArray[ pListKeys[1] ][ pListKeys[2] ][ pListKeys[3] ][ pListKeys[4] ][ pListKeys[5] ][ pListKeys[6] ]
            break
        case 7
            put pValue into pArray[ pListKeys[1] ][ pListKeys[2] ][ pListKeys[3] ][ pListKeys[4] ][ pListKeys[5] ][ pListKeys[6] ][ pListKeys[7] ]
            break
        case 8
            put pValue into pArray[ pListKeys[1] ][ pListKeys[2] ][ pListKeys[3] ][ pListKeys[4] ][ pListKeys[5] ][ pListKeys[6] ][ pListKeys[7] ][ pListKeys[8] ]
            break
        case 9
            put pValue into pArray[ pListKeys[1] ][ pListKeys[2] ][ pListKeys[3] ][ pListKeys[4] ][ pListKeys[5] ][ pListKeys[6] ][ pListKeys[7] ][ pListKeys[8] ][ pListKeys[9] ]
            break
        case 10
            put pValue into pArray[ pListKeys[1] ][ pListKeys[2] ][ pListKeys[3] ][ pListKeys[4] ][ pListKeys[5] ][ pListKeys[6] ][ pListKeys[7] ][ pListKeys[8] ][ pListKeys[9] ][ pListKeys[10] ]
            break
        default
            repeat with x = 1 to pNumKeys
                put empty into tArray
                put pValue into tArray[pListKeys[x]]
                put tArray into pValue
            end repeat

            union pArray with tArray recursively
            break
    end switch

    set the caseSensitive to false
end _builderArray

private function _unicodeEscapes pString
    local tInEsc, tCount, tBuffer, tInEscape, tNString

    put false into tInEsc
    repeat for each char c in pString
        add 1 to tCount
        put c after tBuffer
        if tCount < 2 then next repeat
        if tBuffer is "\u" then put true into tInEsc
        if tInEsc then
            if length(tBuffer) < 6 then
                next repeat
            else
                -- TO DEAL WITH DIACRITICS :
                if platform() is "MacOS" then
                    put isotomac(numToChar(baseconvert(char 3 to 6 of tBuffer, 16, 10))) into tBuffer
                else
                    put numToChar(baseconvert(char 3 to 6 of tBuffer, 16, 10)) into tBuffer
                end if
                put false into tInEsc
            end if
        else
            put char 1 of tBuffer after tNString
            delete char 1 of tBuffer
        end if
    end repeat
    put tBuffer after tNString
    return tNString
end _unicodeEscapes



private function _jsonToUtf8 @pJson
    local tNulls = "1111", tCounter  = "1,2,3,4", bigEndian

    split tCounter by comma
    repeat for each key n in tCounter
        if (byte n of pJson is null) then put 0 into char n of tNulls
    end repeat
    put (char 1 of (binaryencode("I",1)) is null) into bigEndian

    switch tNulls
        case "1111"  -- UTF-8
            return false--pJson
            break
        case "0101"  -- UTF-16BE
            if bigEndian then
                get _utf8encode(pJson, true)
                return false
            else
                get _utf8encode(_swapEndianness(pJson), true)
                return false
            end if
            break
        case "1010"  -- UTF-16LE
            if not bigEndian then
                get _utf8encode(pJson, true)
                return false
            else
                get _utf8encode(_swapEndianness(pJson), true)
                return false
            end if
            break
        case "0001"  -- UTF-32BE
            put "error: 4 byte unicode, can't decode" into pJson
            return true
            break
        case "1000"  -- UTF-32LE
            put "error: 4 byte unicode, can't decode" into pJson
            return true
            break
    end switch
end _jsonToUtf8


private function _swapEndianness pString, pSize
    local tNString
    put empty into tNString
    if pSize is empty then put 2 into pSize
    repeat with n = 1 to length(pString) step pSize
        repeat with s = pSize - 1 down to 0
            put byte n + s of pString  after tNString
        end repeat
    end repeat
    return tNString
end _swapEndianness


private function _utf8encode pString, pIsUnicode
    if pIsUnicode then
        return unidecode(pString, "UTF8")
    else
        return unidecode(uniencode(pString),"UTF8")
    end if
end _utf8encode


private function _utf8decode pString, pToUnicode
    if pToUnicode then
        return uniencode(pString,"UTF8")
    else
        return unidecode(uniencode(pString,"UTF8"))
    end if
end _utf8decode


local sMaxLength
# json beautiful and compact
private function _JsonPrettyCompact  pJsonString, pIndentSize, pForceRootType
    local tFormatted, tIndent, kSpace, tPrevToken = "", tIndex  = 0,  tOpenClose = "",  tItems  = "", tHyphenMinus = false

    if sMaxLength is not an integer then put 50 into sMaxLength
    if pIndentSize is not a integer or pIndentSize > 10 then put 4 into pIndentSize
    if _jsonToUtf8( pJsonString ) is true then return pJsonString

    repeat for pIndentSize
        put space after kSpace
    end repeat

    # escaped quotes < \" > and reverse-solidus < \\ > will confuse the tokenizer
    # so we replace them with "\u0022" and "\u005C" which we'll unescape
    # with all the other unescapes when we parse
    if "\\" is in pJsonString then replace "\\" with "\u005C" in pJsonString
    if backSlash & quote is in pJsonString then replace backSlash & quote with "\u0022" in pJsonString
    if "\/" is in pJsonString then  replace "\/" with "/" in pJsonString

    // In this loop we only get where each JSON object and JSON array begins and ends.
    // For now to measure the size of these to know from where to where is each.
    repeat for each token tToken in pJsonString
        add 1 to tIndex
        if tToken is in "[{" then
            put comma & tIndex  after tItems
        else if tToken is in "]}" then
            put tIndex into tOpenClose[ the item  - 1 of tItems]
            delete the item  - 1 of tItems
        end if
    end repeat


    put 0 into tIndex
    put empty into tItems

    repeat for each token tToken in pJsonString
        add 1 to tIndex
        switch tToken
            case "{"
            case "["
                put kSpace after tIndent
                if the length of (the token tIndex to tOpenClose[ tIndex ] of pJsonString) > sMaxLength then
                    put tToken & cr & tIndent after tFormatted
                    put comma & true after tItems
                else
                    put tToken  after tFormatted
                    put comma & false after tItems
                end if
                break
            case "}"
            case "]"
                delete char  - pIndentSize to - 1 of tIndent
                if the last item of tItems is true then
                    put  cr & tIndent  &   tToken after tFormatted
                else
                    put  tToken after tFormatted
                end if
                delete last item of tItems
                break

            case ":"
                put ": "  after tFormatted
                break

            case comma
                if the last item of tItems is true then
                    put comma  & cr & tIndent  after tFormatted
                else
                    put comma  & space  after tFormatted
                end if
                break

            case "-"
                put true into tHyphenMinus
                next repeat
                break

            default

                if tHyphenMinus then
                    put "-" & tToken into tToken
                    put false into tHyphenMinus
                end if

                replace "\u005C" with "\" in tToken
                replace "\u0022"  with  quote in tToken

                if pForceRootType is "string" then
                    put  _JsonString( tToken ) after tFormatted

                else
                    put _JsonValue( tToken ) after tFormatted

                end if
        end switch

        put tToken into tPrevToken
    end repeat

    return  textDecode( tFormatted, "UTF8")

end _JsonPrettyCompact

