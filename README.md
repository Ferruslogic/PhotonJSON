# PhotonJSON
[Leer en Español](LEEME.md)

LiveCode script library for working with JSON, written in livecode-script and without the use of external.

In this library ideas converge from many developers who created solutions like this in LiveCode and in other programming languages. Although there are several libraries for working with JSON in LiveCode. We it a personal challenge to create our own version for which we took as a basis the great work done by Bob Hall in the FastJSON library. We needed a library like FastJSON and with the speed of Mount Goulding's mergJSON. So we started writing PhotonJSON using FastJSON's ideas and code as a base, although in some cases we completely rewrote the algorithms.



## PhotonJSON improvements.

In PhotonJSON, a certain degree of optimization was achieved in the processes of analyzing a JSON. Therefore, the library has a performance very close to that obtained in mergJSON. Not forgetting that the latter makes use of an external that processes at a lower level than LiveCode and therefore is a little faster. These are some of the improvements we found in PhotonJSON.
1. Convert a JSON to an LC Array in a less time equal to or very close to that of mergJSON.
2. When converting an LC Array to JSON you can specify whether the JSON is beautifully formatted.
3. Added a nice formatting function and another to minify existing JSON.



## How to use PhotonJSON

To use PhotonJSON in your desktop or mobile applications you just have to load the library

```
start using stack "PhotonJSON"
```

If you are going to use PhotonJSON in your server application, you must create a plain text file with the extension .lc and copy the script from the PhotonJSON stack to this file without including the first line of it ("PhotonJSON" script).

```
<? lc ... the script of stack"PhotonJSON" ...?>
```

We already have PhotonJSON integrated into our project. So, we can access all the functions and properties of it.



> **NOTE**
> *Before continuing, let's clarify that in LiveCode if two libraries have a function with the same name. If this function is called from any other side of the code, the one from the last library that was called will be executed, that is, the one that is first in the message path.*



PhotonJSON has 5 functions and a public property that is, they can be accessed from another script. It also integrates 4 functions for compatibility with projects that use other libraries and want to start using this one. Please note the above note.

| Name          | Type     | Parameter                                                    | Returns           | Description                                            |
| :------------ | -------- | ------------------------------------------------------------ | ----------------- | ------------------------------------------------------ |
| cVersion      | property |                                                              | Version           | The current version of the library.                    |
| validateJSON  | function | UTF-8 JSON string                                            | Boolean           | Validate if a string is a valid JSON.                  |
| beautifyJSON  | function | J UTF-8 JSON string                                          | UTF-8 JSON string | JSON string formatted in a more visually pleasing way. |
| minifyJSON    | function | UTF-8 JSON string                                            | UTF-8 JSON string | Remove unnecessary spaces from JSON string.            |
| JSONStringify | function | LC Array, if the type of the JSON elements is forced and if it is formatted in a beautiful way | UTF-8 JSON string | Gets the JSON string from an LC Array.                 |
| JSONParser    | function | UTF-8 JSON string                                            | LC Array          | Gets the LC Array of a JSON string.                    |

These are the four functions that are optionally included for PhotonJSON compatibility with projects that use mergeJSON or FastJSON. They expect the same parameters as in their original versions and in the same order.

```
ArrayToJSON(), JsonToArray(), arrayFromJson(), and jsonFromArray().
```

If you don't want PhotonJSON to overwrite the previous functions, just comment the code for it in the PhotonJSON library.



>**Why don't we use these names for the library and use JSONStringify and JSONParser as in the HTML5 API.**
>*Since we created this library to be used in a plugin that will be integrated with the LiveCode IDE and as we clarify in the note. When a function is called and it is in two libraries, the first one in the path will take precedence over the others. So in order not to interfere with other projects where you don't want to use this library, we decided to use this naming convention and not include the others.*



### Copyright (C) 2020 [FerrusLogic S.A.](https://ferruslogic.com/)
