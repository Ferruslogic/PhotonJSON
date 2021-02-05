script "PhotonJSON"
--------------------------------------------------------------------------------------------------------------------------
#  Name: PhotonJSON
#  Type: Library
#  Version: v1.0.4
#  Author: FerrusLogic
#  Code repository: https://github.com/Ferruslogic/PhotonJSON/
#  Web: https://ferruslogic.com/
#  License: https://opensource.org/licenses/MIT
#  Description: LiveCode script library for working with JSON, written in livecode-script and without the use of external.
#  Note: PhotonJSON follows JSON's standards presented in https://www.json.org/json-en.html
#  Date: Nov 2020
--------------------------------------------------------------------------------------------------------------------------

#  declare script local variables
local sSpace  = ""
local sIndentSize = 4

# declare constants
constant kVersion = "1.0.4", kSpaces = "    "

# The current version of the library.
getProp cVersion
   return kVersion
end cVersion

-----------------------------------------------------------------------------
--- These functions are for compatibility with projects that use mergJSON ---
-----------------------------------------------------------------------------
--function jsonToArray pJSON
--    return JSONParser(pJSON,true) for value
--end jsonToArray


--function arrayToJson pArray, pForceRootType, pPretty
--  return JSONStringify(pArray,pPretty,true)  for value
--end arrayToJson

-----------------------------------------------------------------------------
--- These functions are for compatibility with projects that use FASTJSON ---
-----------------------------------------------------------------------------
function arrayFromJson pJson
    return JSONParser(pJSON,true)  for value
end arrayFromJson

function jsonFromArray pArray, pForceRootType, pPretty
  return JSONStringify(pArray,pPretty,true)  for value
end jsonFromArray

-----------------------------------------------------------------------------
-------------------------- CODE OF LIBRARY ----------------------------------
-----------------------------------------------------------------------------

# validateJSON: Validate if a string is a valid JSON.
# Parameter: The JSON to evaluate. (String)
# returns: A boolean. (Boolean)
function validateJSON pJsonString
   local tCont = 0, tTokenCont = 0, tSplit

   # escaped quotes < \" > and reverse-solidus < \\ > will confuse the tokenizer
   # so we replace them with "\u0022" and "\u005C" which we'll unescape
   # with all the other unescapes when we parse
   replace "\\" with "\u005C" in pJsonString
   replace (backSlash & quote) with "\u0022" in pJsonString

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
               return false  for value
            end if
            break
      end switch

      if tToken begins with "0" then
         put the token (tTokenCont - 1) to (tTokenCont + 1) of pJsonString into tSplit

         split tSplit by quote

         if tSplit[2] is not tToken then
            return false  for value
         end if
      end if
   end repeat

   return (tCont is 0 ) for value
end validateJSON


# beautifyJSON: JSON string formatted in a more visually pleasing way.
# Parameter:
# 1: JSON string (String)
# 2: Numbers of spaces in Indent (Integer)
# 3: Whether it is treated as Unicode (Boolean)
# returns: JSON string (String)
function beautifyJSON pJsonString, pIndentSize, pAsUnicode
   local tArray

   if pIndentSize is a integer then put pIndentSize into sIndentSize
   else put 4 into sIndentSize

   put JSONParser(pJsonString, pAsUnicode) into tArray

   if tArray is an array then
      return JSONStringify(tArray, true, pAsUnicode)  for value
   end if
end beautifyJSON

# minifyJSON: Remove unnecessary spaces from JSON string.
# Parameter:
# 1: JSON string (String)
# 2: if it is treated as Unicode (Boolean)
# returns: JSON string (String)
function minifyJSON pJsonString, pAsUnicode
   local tArray

   put JSONParser(pJsonString, pAsUnicode) into tArray

   if tArray is an array then
      return JSONStringify(tArray, false, pAsUnicode) for value
   end if
end minifyJSON

# JSONStringify: Gets the JSON string from an LC Array.
# Parameter:
# 1: LC Array (Array)
# 2: if JSON is formatted nice (Boolean)
# 3: if it is treated as Unicode (Boolean)
# returns: JSON string (String)
function JSONStringify pArray, pPretty, pAsUnicode
    local tJson
    if pArray is not an array then return empty  for value-- "Parser Error: parameter given is not an array."

    if pPretty is not true then
        put _builderJSON(pArray, pAsUnicode) into tJson
    else
        put _builderJsonPretty(pArray, pAsUnicode) into tJson
    end if

    delete variable sSpace

    return tJson  for value
end JSONStringify


# JSONParser: Gets the LC Array of a JSON string
# Parameter:
# 1: JSON string (String)
# 2: if it is treated as Unicode (Boolean)
# returns: LC Array (Array)
function JSONParser pJsonString, pAsUnicode
    local tKeyNameOrValue = 0, tArrayKeysPath , tNumKeys = 0 ,tOpenJArray, tResultArray, tHyphenMinus

    if pJsonString is empty then return empty  for value

    if _jsonToUtf8(pJsonString ) is true then return pJsonString for value

    # escaped quotes < \" > and reverse-solidus < \\ > will confuse the tokenizer
    # so we replace them with "\u0022" and "\u005C" which we'll unescape
    # with all the other unescapes when we parse
    replace "\\" with "\u005C" in pJsonString
    replace (backSlash & quote) with "\u0022" in pJsonString

    local tOldToken, tObjEmpty = ""

    repeat for each token tToken in pJsonString

        # Fix bug when JSON has empty objects
        if tOldToken is "{" and tToken is "}" then _builderArray tObjEmpty, tArrayKeysPath, tResultArray, tNumKeys
        if tNumKeys < 0  then put 0 into tNumKeys

        put tToken into tOldToken


        switch tToken

            case "{"
                put 0 into tKeyNameOrValue
                next repeat
                break

            case "["
                put 1 into tKeyNameOrValue
                add 1 to tNumKeys
                put 1 into tArrayKeysPath[tNumKeys]
                put tNumKeys into tOpenJArray[tNumKeys]
                next repeat
                break

            case "}"
                delete variable tArrayKeysPath[tNumKeys]
                subtract 1 from tNumKeys
                next repeat
                break

            case comma
                if tOpenJArray[tNumKeys] <> empty then
                    if tArrayKeysPath[tNumKeys] is a integer then
                        add 1 to tArrayKeysPath[tNumKeys]
                        put 1 into tKeyNameOrValue
                    end if
                else
                    delete variable tArrayKeysPath[tNumKeys]
                    subtract 1 from tNumKeys
                    put 0 into tKeyNameOrValue
                end if
                next repeat
                break

            case colon
                put 1 into tKeyNameOrValue
                next repeat
                break

            case "]"
                delete variable tArrayKeysPath[tNumKeys]
                delete variable tOpenJArray[tNumKeys]
                subtract 1 from tNumKeys
                put 0 into tKeyNameOrValue
                next repeat
                break

            case "-"
                put true into tHyphenMinus
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


        if pAsUnicode then
            put _utf8decode(tToken) into tToken
        end if

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

    return tResultArray  for value
end JSONParser

command setIndentSize pNum
   if pNum is a integer and pNum > 0 then
      put pNum into sIndentSize

   else
      put 0 into sIndentSize
   end if
end setIndentSize

function getIndentSize
   return sIndentSize  for value
end getIndentSize

private function  _builderJson pArray, pAsUnicode
    local tJSON, tKeys

    put the keys of pArray into tKeys
    filter tKeys without "[0-9]*"

    if tKeys is empty then
        # the array's keys are all *numerical*, so the root element will be a JSON *array*
        put "[" into tJSON
        repeat for each element tValue in pArray
            put _jsonValue(tValue, pAsUnicode) & comma after tJSON
        end repeat
        put "]" into the last char of tJSON
    else
        put the keys of pArray into tKeys
        sort lines of tKeys ascending international
        # the array's keys are not all numerical, so the root element will be a JSON *object*
        put "{" into tJSON

        repeat for each line tKey in tKeys

            put quote & _jsonString( tKey ) & quote & ":" & _jsonValue(pArray[tKey], pAsUnicode) & comma after tJSON
        end repeat

        put "}" into the last char of tJSON
    end if

    return tJSON  for value
end _builderJSON

private function _builderJsonPretty pArray, pAsUnicode
    local tJSON, tValue, tKey, tIsNumericalArray, tKeyValue, tOldSpace, tKeys

    put the keys of pArray into tKeys
    filter tKeys without "[0-9]*"

    if sIndentSize is 4 or sIndentSize is not a integer then
        put kSpaces after sSpace

    else if sIndentSize is a integer then

        repeat for sIndentSize
            put space after sSpace
        end repeat

    end if

    if tKeys is empty then
        put "[" into tJSON

        put _jsonValuePretty(pArray[1], pAsUnicode) into tKeyValue

        delete variable pArray[1]

        if tKeyValue ends with "}" then
            if pArray is empty then

                put sSpace into tOldSpace
                delete char - sIndentSize to - 1 of sSpace

                replace tOldSpace with sSpace in tKeyValue

                put tKeyValue & "]" after tJSON
                return tJSON  for value
            else
                put tKeyValue & "," & return after tJSON
            end if
        else
            put tKeyValue & "," after tJSON
        end if

        repeat for each element tValue in pArray
            put _jsonValuePretty(tValue, pAsUnicode) into tKeyValue

            if tKeyValue ends with "}" then
                put sSpace & tKeyValue & "," & return after tJSON
            else
                put space & tKeyValue & "," after tJSON
            end if

        end repeat

        delete char - sIndentSize to - 1 of sSpace

        if tKeyValue ends with "}" then
            put return & sSpace & "]" into char - 2 to - 1 of tJSON
        else
            put  "]" into char - 1 of tJSON
        end if

    else

        put the keys of pArray into tKeys
        sort lines of tKeys ascending international

        put "{" & return into tJSON

        repeat for each lines tKey in tKeys
            put sSpace & quote & _jsonString( tKey ) & quote & ": " & _jsonValuePretty( pArray[tKey] , pAsUnicode) & "," & return  after tJSON
        end repeat

        delete char - sIndentSize to - 1 of sSpace

        put return & sSpace & "}" into char - 2 to - 1 of tJSON
    end if

    return tJSON  for value
end _builderJsonPretty

private command _builderArray @pValue, @pListKeys, @pArray, @pNumKeys
    local tArray

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

end _builderArray


private function _jsonToUtf8 @pJson
    local tNulls = "1111"
    local tCounter  = "1,2,3,4"
    local bigEndian

    split tCounter by comma

    repeat for each key n in tCounter
        if (byte n of pJson is null) then put 0 into char n of tNulls
    end repeat

    put (char 1 of (binaryencode("I",1)) is null) into bigEndian

    switch tNulls
        case "1111"  -- UTF-8
            return false for value--pJson
            break

        case "0101"  -- UTF-16BE
            if bigEndian then
                get _utf8encode(pJson, true)
                return false for value
            else
                get _utf8encode(_swapEndianness(pJson), true)
                return false for value
            end if
            break

        case "1010"  -- UTF-16LE
            if not bigEndian then
                get _utf8encode(pJson, true)
                return false for value
            else
                get _utf8encode(_swapEndianness(pJson), true)
                return false for value
            end if
            break

        case "0001"  -- UTF-32BE
            put "error: 4 byte unicode, can't decode" into pJson
            return true for value
            break

        case "1000"  -- UTF-32LE
            put "error: 4 byte unicode, can't decode" into pJson
            return true for value
            break

    end switch

end _jsonToUtf8


private function _jsonValue @pValue, @pAsUnicode
    switch
    case pValue is an array
        # this allows us to have nested JSON objects and arrays:
        return _builderJSON(pValue, pAsUnicode) for value
        break

    case pValue is empty
        return "null" for value
        break

    case pValue is a boolean
        return pValue for value
        break

    case pValue is a number
        # in the case that it is a constant. Infinity, pi ...
        if pValue is not in "pi,eight,five,four,infinity,nine,one,scrollbarFactor,seven,six,ten,three,two,zero" then

            # negative numbers or 0.N
            if pValue < 1 and pValue then return pValue for value

            # need to catch when a "number" starts with a 0
            # decided to return this as a quoted string
            # JSON lint throws an exception if a number starts with a 0
            if the first char of pValue is not 0 or pValue is 0 then
                return pValue for value
            else
                return quote & pValue & quote for value
            end if

        else
            return quote & pValue & quote for value
        end if

        break

    default
        # any other value is processed as a string.
        # JSON strings require that certain characters be 'escaped' with a backslash:
        if "\" is in pValue then replace "\" with "\\" in pValue
        if quote is in pValue then replace quote with "\" & quote in pValue
        if "/" is in pValue then replace "/" with "\/" in pValue
        if numToChar(8) is in pValue then replace numToChar(8) with "\b" in pValue
        if numToChar(9) is in pValue then replace numToChar(9) with "\t" in pValue
        if numToChar(10) is in pValue then replace numToChar(10) with "\n" in pValue
        if numToChar(12) is in pValue then replace numToChar(12) with "\f" in pValue
        if numToChar(13) is in pValue then replace numToChar(13) with "\r" in pValue

        if pAsUnicode then
            return quote & _utf8encode(pValue) & quote for value
        else
            return quote & pValue & quote for value
        end if
    end switch
end _jsonValue


private function _jsonString pValue
    # In a JSON object, the names of its keys are strings.
    # So these characters escape in case they are there.

    # https://www.json.org/img/string.png
    # any other value is processed as a string.
    # JSON strings require that certain characters be 'escaped' with a backslash:
    # This makes the processing a bit slower. But it is necessary for it to comply with the ECMA-404 standard
    if "\" is in pValue then replace "\" with "\\" in pValue
    if quote is in pValue then replace quote with "\" & quote in pValue
    if "/" is in pValue then replace "/" with "\/" in pValue
    if numToChar(8) is in pValue then replace numToChar(8) with "\b" in pValue
    if numToChar(9) is in pValue then replace numToChar(9) with "\t" in pValue
    if numToChar(10) is in pValue then replace numToChar(10) with "\n" in pValue
    if numToChar(12) is in pValue then replace numToChar(12) with "\f" in pValue
    if numToChar(13) is in pValue then replace numToChar(13) with "\r" in pValue

    return pValue for value
end _jsonString

private function _jsonValuePretty  @pValue, @pAsUnicode

    switch
    case pValue is an array
        # this allows us to have nested JSON objects and arrays:
        return _builderJsonPretty(pValue, pAsUnicode) for value
        break

    case pValue is empty
        return "null" for value
        break

    case pValue is a boolean
        return pValue for value
        break

    case pValue is a number
        # in the case that it is a constant. Infinity, pi ...
        if pValue is not in "pi,eight,five,four,infinity,nine,one,scrollbarFactor,seven,six,ten,three,two,zero" then

            # negative numbers or 0.N
            if pValue < 1 and pValue then return pValue for value

            # need to catch when a "number" starts with a 0
            # decided to return this as a quoted string
            # JSON lint throws an exception if a number starts with a 0
            if the first char of pValue is not 0 or pValue is 0 then
                return pValue for value
            else
                return quote & pValue & quote for value
            end if

        else
            return quote & pValue & quote for value
        end if

        break

    default
        # any other value is processed as a string.
        # JSON strings require that certain characters be 'escaped' with a backslash:
        if "\" is in pValue then replace "\" with "\\" in pValue
        if quote is in pValue then replace quote with "\" & quote in pValue
        if "/" is in pValue then replace "/" with "\/" in pValue
        if numToChar(8) is in pValue then replace numToChar(8) with "\b" in pValue
        if numToChar(9) is in pValue then replace numToChar(9) with "\t" in pValue
        if numToChar(10) is in pValue then replace numToChar(10) with "\n" in pValue
        if numToChar(12) is in pValue then replace numToChar(12) with "\f" in pValue
        if numToChar(13) is in pValue then replace numToChar(13) with "\r" in pValue


        if pAsUnicode then
            return quote & _utf8encode(pValue) & quote for value
        else
            return quote & pValue & quote for value
        end if
    end switch
end _jsonValuePretty

private function _swapEndianness pString, pSize
    local tNString

    put empty into tNString

    if pSize is empty then put 2 into pSize

    repeat with n = 1 to length(pString) step pSize
        repeat with s = pSize - 1 down to 0
            put byte n + s of pString  after tNString
        end repeat
    end repeat

    return tNString for value
end _swapEndianness


private function _utf8encode pString, pIsUnicode
    if pIsUnicode then
        return unidecode(pString, "UTF8") for value
    else
        return unidecode(uniencode(pString),"UTF8") for value
    end if
end _utf8encode

private function _utf8decode pString, pToUnicode
    if pToUnicode then
        return uniencode(pString,"UTF8") for value
    else
        return unidecode(uniencode(pString,"UTF8")) for value
    end if
end _utf8decode

-------------------------------
-- lcLibJson v1.0b
-- Christopher Armstrong
-- Date: Nov 2014
-------------------------------
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
    return tNString for value
end _unicodeEscapes

