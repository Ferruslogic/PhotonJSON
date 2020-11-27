﻿script "PhotonJSON"
/*
*  Name: PhotonJSON
*  Type: Library
*  Version: v1.0.0
*  Author: FerrusLogic
*  Code repository: https://github.com/Ferruslogic/PhotonJSON/
*  Web: https://ferruslogic.com/
*  License: https://opensource.org/licenses/MIT
*
*  Description: LiveCode script library for working with JSON, written in livecode-script and without the use of external.
*/


local sSpace  = ""

constant kVersion = "1.0.0"
constant kSpaces = "    "


getProp cVersion
   return kVersion
end cVersion

-----------------------------------------------------------------------------
--- These functions are for compatibility with projects that use mergJSON ---
-----------------------------------------------------------------------------
function jsonToArray pJSON
   return JSONParser(pJSON,true)
end jsonToArray


function arrayToJson pArray, pForceRootType, pPretty
   return JSONStringify(pArray,pPretty,true)
end arrayToJson

-----------------------------------------------------------------------------
--- These functions are for compatibility with projects that use FASTJSON ---
-----------------------------------------------------------------------------
function arrayFromJson pJson
   return JSONParser(pJSON,true)
end arrayFromJson

function jsonFromArray pArray, pForceRootType, pPretty
   return JSONStringify(pArray,pPretty,true)
end jsonFromArray

-----------------------------------------------------------------------------
-------------------------- CODE OF LIBRARY ----------------------------------
-----------------------------------------------------------------------------

# validateJSON: Validate if a string is a valid JSON.
# Parameter: The JSON to evaluate. (String)
# returns: A boolean. (Boolean)
function validateJSON pJsonString
   local tCont = 0, tTokenCont = 0, tSplit

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
               return false
            end if
            break
      end switch

      if tToken begins with "0" then
         put the token (tTokenCont - 1) to (tTokenCont + 1) of pJsonString into tSplit

         split tSplit by quote

         if tSplit[2] is not tToken then
            return false
         end if
      end if
   end repeat

   return tCont is 0
end validateJSON


# beautifyJSON: JSON string formatted in a more visually pleasing way.
# Parameter:
# 1: JSON string (String)
# 2: Numbers of spaces (Integer)
# 3: Whether it is treated as Unicode (Boolean)
# returns: JSON string (String)
function beautifyJSON pJsonString, pIndentSize, pAsUnicode
   local tIndent, tPrevToken, tFormatted, tType, tCurrentIndent, tGet

   if pIndentSize is not a integer then put 4 into pIndentSize

   repeat for pIndentSize
      put space after tIndent
   end repeat

   replace (backSlash & quote) with "\u0022" in pJsonString

   repeat for each token tToken in pJsonString
      switch tToken

         case "{"
            put 1 into tType

            if tPrevToken is comma then
               put return & tCurrentIndent & "{" after tFormatted
            else
               put "{" after tFormatted
            end if

            put tIndent after tCurrentIndent
            put tToken into tPrevToken

            next repeat
            break

         case "["
            put 0 into tType

            if tPrevToken is in "[," then
               put return & tCurrentIndent & "[" after tFormatted
            else
               put "[" after tFormatted
            end if

            put tIndent after tCurrentIndent
            put tToken into tPrevToken

            next repeat
            break

         case "}"
            delete char - (pIndentSize) to - 1 of tCurrentIndent
            put 1 into tType

            if tPrevToken is "]" then
               put tPrevToken & tToken into last token tFormatted
            else
               put return & tCurrentIndent & tToken after tFormatted
            end if
            put tToken into tPrevToken

            next repeat
            break

         case "]"
            delete char - (pIndentSize) to - 1 of tCurrentIndent
            put 1 into tType

            if tToken is "]" and tPrevToken  is not in "]}" then

               put tToken after tFormatted
               put empty into tPrevToken

               next repeat
            else

               put return & tCurrentIndent & tToken after tFormatted
            end if

            put tToken into tPrevToken

            next repeat
            break

         case "-"
            put tToken into tPrevToken
            put "-" after tFormatted

            next repeat
            break

         case ":"
            put tToken into tPrevToken
            put ": " after tFormatted
            put 0 into tType
            next repeat
            break

         case ","
            if tPrevToken is in "]}" then
               put comma  after tFormatted
               put tToken into tPrevToken
               next repeat
            end if

            if tGet is 2 and tPrevToken is not  "}" then
               put comma & return & tCurrentIndent  after tFormatted
               put 0 into tGet
            else
               put comma & space after tFormatted
            end if

            put tToken into tPrevToken
            next repeat
            break
      end switch


      put tToken into tPrevToken
      if "\u0022" is in tToken then replace "\u0022"  with  quote in tToken

      if tType is 1 then
         # any other value is processed as a string.
         # JSON strings require that certain characters be 'escaped' with a backslash:
         if "\"  is in tToken then replace "\" with "\\" in tToken // the backslash itself
         if quote is in tToken then replace quote with "\" & quote in tToken // the double quote
         if "/" is in tToken then replace "/" with "\/" in tToken // the (forward) slash
         if tab is in tToken then replace tab with "\t" in tToken // the tab
         if return is in tToken then replace return with "\n" in tToken // the return

         if pAsUnicode and tToken is not a ASCII String then
            put _utf8encode(tToken) into tToken
         end if

         put return & tCurrentIndent & quote & tToken & quote after tFormatted
         put 1 into tGet -- get the key name
         next repeat
      end if

      put _jsonValue(tToken,false,pAsUnicode) after tFormatted
      -- get the key value
      add 1 to tGet
   end repeat

   return tFormatted
end beautifyJSON

# minifyJSON: Remove unnecessary spaces from JSON string.
# Parameter:
# 1: JSON string (String)
# 2: if it is treated as Unicode (Boolean)
# returns: JSON string (String)
function minifyJSON pJsonString, pAsUnicode
   local tFormatted, tType

   replace (backSlash & quote) with "\u0022" in pJsonString

   local tGet

   repeat for each token tToken in pJsonString
      switch tToken

         case "{"
            put 1 into tType
            put "{" after tFormatted
            next repeat
            break

         case "["
            put 0 into tType
            put "[" after tFormatted
            next repeat
            break

         case "}"
            put 1 into tType
            put tToken after tFormatted
            next repeat

            break
         case "]"
            put 1 into tType
            put tToken after tFormatted
            next repeat
            break

         case "-"
            put "-" after tFormatted
            next repeat
            break

         case ":"
            put ":" after tFormatted
            put 0 into tType
            next repeat
            break

         case ","
            put comma  after tFormatted
            next repeat
            break
      end switch


      if "\u0022" is in tToken then replace "\u0022"  with  quote in tToken

      if tType is 1 then
         # any other value is processed as a string.
         # JSON strings require that certain characters be 'escaped' with a backslash:
         if "\"  is in tToken then replace "\" with "\\" in tToken // the backslash itself
         if quote is in tToken then replace quote with "\" & quote in tToken // the double quote
         if "/" is in tToken then replace "/" with "\/" in tToken // the (forward) slash
         if tab is in tToken then replace tab with "\t" in tToken // the tab
         if return is in tToken then replace return with "\n" in tToken // the return

         if pAsUnicode and tToken is not a ASCII String then
            put _utf8encode(tToken) into tToken
         end if

         put quote & tToken & quote after tFormatted
         put 1 into tGet -- get the key name
         next repeat
      end if

      put _jsonValue(tToken,false,pAsUnicode) after tFormatted
      add 1 to tGet -- get the key value
   end repeat

   return tFormatted
end minifyJSON

# JSONStringify: Gets the JSON string from an LC Array.
# Parameter:
# 1: LC Array (Array)
# 2: if JSON is formatted nice (Boolean)
# 3: if it is treated as Unicode (Boolean)
# returns: JSON string (String)
function JSONStringify pArray, pPretty, pAsUnicode
   local tJSON, tValue, tKey, tIsNumericalArray, tKeyValue, tOldSpace
   local tKeys

   if pArray is not an array then return empty -- "Parser Error: parameter given is not an array."

   put the keys of pArray into tKeys
   filter tKeys without "[0-9]*"

   if tKeys is not empty then
      put 0 into tIsNumericalArray
   else
      put 1 into tIsNumericalArray
   end if

   if pPretty is true then
      put kSpaces after sSpace

      if tIsNumericalArray is 1 then
         put "[" into tJSON

         put _jsonValue(pArray[1], true, pAsUnicode) into tKeyValue

         delete variable pArray[1]

         if tKeyValue ends with "}" then
            if pArray is empty then

               put sSpace into tOldSpace
               delete char - 4 to - 1 of sSpace

               replace tOldSpace with sSpace in tKeyValue

               put tKeyValue &"]" after tJSON
               return tJSON
            else
               put tKeyValue & "," & return after tJSON
            end if
         else
            put tKeyValue & "," after tJSON
         end if

         repeat for each element tValue in pArray
            put _jsonValue(tValue, true, pAsUnicode) into tKeyValue

            if tKeyValue ends with "}" then
               put sSpace & tKeyValue & "," & return after tJSON
            else
               put space & tKeyValue & "," after tJSON
            end if

         end repeat

         delete char - 4 to - 1 of sSpace

         if tKeyValue ends with "}" then
            put return & sSpace & "]" into char - 2 to - 1 of tJSON
         else
            put  "]" into char - 1 of tJSON
         end if

      else

         put "{" & return into tJSON

         repeat for each key tKey in pArray
            put sSpace & quote & tKey & quote & ": " & _jsonValue( pArray[tKey] , true, pAsUnicode) & "," & return  after tJSON
         end repeat

         delete char - 4 to - 1 of sSpace

         put return & sSpace & "}" into char - 2 to - 1 of tJSON
      end if

   else

      if tIsNumericalArray is 1 then
         # the array's keys are all *numerical*, so the root element will be a JSON *array*
         # if keepNumeric is true, then the keys will remain numeric keys
         put "[" into tJSON
         repeat for each element tValue in pArray
            put _jsonValue(tValue, false, pAsUnicode) & comma after tJSON
         end repeat
         put "]" into the last char of tJSON
      else
         # the array's keys are not all numerical, so the root element will be a JSON *object*
         put "{" into tJSON
         repeat for each key tKey in pArray
            put quote & tKey & quote & ":" & _jsonValue(pArray[tKey], false, pAsUnicode) & comma after tJSON
         end repeat
         put "}" into the last char of tJSON
      end if
   end if

   return tJSON
end JSONStringify


# JSONParser: Gets the LC Array of a JSON string
# Parameter:
# 1: JSON string (String)
# 2: if it is treated as Unicode (Boolean)
# returns: LC Array (Array)
function JSONParser pJsonString, pIsUnicode
   local tKeyNameOrValue = 0, tArrayKeysPath , tNumKeys = 0 ,tOpenJArray, tResultArray, tHyphenMinus = false

   if pIsUnicode is not false then
      put _jsonToUtf8( pJsonString ) into pJsonString

      if pJsonString begins with "error:" then
         return pJsonString
      end if
   end if

   replace (backSlash & quote) with "\u0022" in pJsonString

   repeat for each token tToken in pJsonString

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

         case ","
            if tOpenJArray[tNumKeys] <> empty then
               add 1 to tArrayKeysPath[tNumKeys]
               put 1 into tKeyNameOrValue
            else
               delete variable tArrayKeysPath[tNumKeys]
               subtract 1 from tNumKeys
               put 0 into tKeyNameOrValue
            end if
            next repeat
            break

         case ":"
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

      if "\" is in tToken then
         if ("\" & quote) is in tToken then replace ("\" & quote) with quote in tToken
         if "\u0022" is in tToken then replace "\u0022" with quote in tToken
         if "\n" is in tToken then replace "\n" with return in tToken
         if "\r" is in tToken then replace "\n" with cr in tToken
         if "\t" is in tToken then replace "\t" with tab in tToken
         if "\\" is in tToken then replace "\\" with "\" in tToken
         if "\/" is in tToken then replace "\/" with "/" in tToken
         if "\r\n" is in tToken then replace "\r\n" with return in tToken
         if "\f" is in tToken then replace "\f" with return in tToken
         if "\u" is in tToken then put _unicodeEscapes(tToken) into tToken
      end if


      if pIsUnicode is true and tToken is not a ASCII String then
         put _utf8decode(tToken) into tToken
      end if

      if tKeyNameOrValue = 1 then

         if tHyphenMinus is true then
            put "-" & tToken into tToken
            put false into tHyphenMinus
         end if

         if "null" is tToken then put empty into tToken

         _arrayBilder tToken, tArrayKeysPath, tResultArray, tNumKeys

      else if tKeyNameOrValue = 0 then

         add 1 to tNumKeys
         put tToken into tArrayKeysPath[tNumKeys]

      end if
   end repeat

   return tResultArray
end JSONParser


private command _arrayBilder @pValue, @pListKeys, @pArray, @pNumKeys
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

end _arrayBilder


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
         return pJson
         break

      case "0101"  -- UTF-16BE
         if bigEndian then
            return _utf8encode(pJson, true)
         else
            return _utf8encode(swapEndianness(pJson), true)
         end if
         break

      case "1010"  -- UTF-16LE
         if not bigEndian then
            return _utf8encode(pJson, true)
         else
            return _utf8encode(swapEndianness(pJson), true)
         end if
         break

      case "0001"  -- UTF-32BE
         return "error: 4 byte unicode, can't decode"
         break

      case "1000"  -- UTF-32LE
         return "error: 4 byte unicode, can't decode"
         break

   end switch

end _jsonToUtf8

private function _jsonValue @pValue, pPretty, @pAsUnicode
   switch
      case pValue is an array
         # this allows us to have nested JSON objects and arrays:
         return JSONStringify(pValue, pPretty, pAsUnicode)
         break

      case pValue is empty
      case pValue is null
         return "null"
         break

      case pValue is a boolean
         return true is pValue
         break

      case pValue is a number
         get the char 1 to 2 of word 1 of pValue
         # negative numbers or 0.N
         if pValue < 1 and pValue then return pValue

         # in the case that it is a constant. Infinity, pi or any other
         if it is a integer then

            # need to catch when a "number" starts with a 0
            # decided to return this as a quoted string
            # JSON lint throws an exception if a number starts with a 0
            if the char 1 of it is not 0 or pValue is 0 then
               return pValue
            else
               return quote & pValue & quote
            end if

         else
            return quote & pValue & quote
         end if
         break

      default
         # any other value is processed as a string.
         # JSON strings require that certain characters be 'escaped' with a backslash:
         if "\"  is in pValue then replace "\" with "\\" in pValue // the backslash itself
         if quote is in pValue then replace quote with "\" & quote in pValue // the double quote
         if "/" is in pValue then replace "/" with "\/" in pValue // the (forward) slash
         if tab is in pValue then replace tab with "\t" in pValue // the tab
         if return is in pValue then replace return with "\n" in pValue // the return

         if pAsUnicode and pValue is not a ASCII String then
            return quote & _utf8encode(pValue) & quote
         else
            return quote & pValue & quote
         end if
   end switch
end _jsonValue



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
               put isotomac(numtochar(baseconvert(char 3 to 6 of tBuffer, 16, 10))) into tBuffer
            else
               put numtochar(baseconvert(char 3 to 6 of tBuffer, 16, 10)) into tBuffer
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