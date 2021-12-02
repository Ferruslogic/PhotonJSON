[![Donate](https://img.shields.io/badge/Donate-QvaPay-green.svg)](https://qvapay.com/payme/ferruslogic?r_id=PhotonJSON&msg=Donate%20to%20Ferruslogic)
# PhotonJSON
[Reading in English](README.md)

Biblioteca de LiveCode scripts para trabajar con JSON, escrito en livecode-script y sin el uso de externos.

En esta biblioteca, convergen las ideas de muchos desarrolladores que crearon soluciones como esta en LiveCode y en otros lenguajes de programación. Aunque existen varias bibliotecas para trabajar con JSON en LiveCode. Nos planteamos un reto personal, crear nuestra propia versión para lo cual tomamos como base el gran trabajo realizado por Bob Hall en la librería FastJSON. Necesitábamos una biblioteca como FastJSON y con la velocidad del mergJSON de Mount Goulding. Así que empezamos a escribir PhotonJSON usando las ideas y el código de FastJSON como base, aunque en algunos casos reescribimos por completo los algoritmos.
## Mejoras de PhotonJSON.

Biblioteca de LiveCode scripts para trabajar con JSON, escrito en livecode-script y sin el uso de externos.

En esta biblioteca, convergen las ideas de muchos desarrolladores que crearon soluciones como esta en LiveCode y en otros lenguajes de programación. Aunque existen varias bibliotecas para trabajar con JSON en LiveCode. Nos planteamos un reto personal, crear nuestra propia versión para lo cual tomamos como base el gran trabajo realizado por Bob Hall en la librería FastJSON. Necesitábamos una biblioteca como FastJSON y con la velocidad del mergJSON de Mount Goulding. Así que empezamos a escribir PhotonJSON usando las ideas y el código de FastJSON como base, aunque en algunos casos reescribimos por completo los algoritmos.
En PhotonJSON, se logró cierto grado de optimización en los procesos de análisis de un JSON. Por tanto, la librería tiene un rendimiento muy cercano al obtenido en mergJSON. Sin olvidar que este último hace uso de un externo que procesa a un nivel menor que LiveCode y por tanto es un poco más rápido. Estas son algunas de las mejoras que encontramos en PhotonJSON.
1. Convierta un JSON en un Array LC en un tiempo menor, igual o muy cercano al de mergJSON.
2. Al convertir un Array LC a JSON, puede especificar si el JSON tiene un formato bonito.
3. Se agrega una función de formato agradable y otra para minimizar los JSON existentes.

## Como usar PhotonJSON

Para utilizar PhotonJSON en su escritorio o aplicaciones móviles solo tiene que cargar la biblioteca

```
start using stack"PhotonJSON"
```

Si va a utilizar PhotonJSON en su aplicación de servidor, debe crear un archivo de texto sin formato con la extensión .lc y copiar el script de la pila PhotonJSON a este archivo sin incluir la primera línea (script "PhotonJSON").

```
<? lc ... el script de la pila "PhotonJSON" ...?>
```

Ya tenemos PhotonJSON integrado en nuestro proyecto. Entonces, podemos acceder a todas las funciones y propiedades de la biblioteca.

> **NOTA**
>
> *Antes de continuar, aclaremos que en LiveCode si dos bibliotecas tienen una función con el mismo nombre. Si se llama a esta función desde cualquier otro lado del código, se ejecutará la de la última biblioteca que se llamé, es decir, la primera en la ruta del mensaje. *

PhotonJSON tiene 5 funciones y una propiedad pública que se puede acceder a ellas desde otro script. También integra 4 funciones para compatibilidad con proyectos que usan otras bibliotecas y quieren comenzar a usar esta. Tenga en cuenta la nota anterior.

| Nombre        | Tipo      | Parámetro                                                    | Devoluciones       | Descripción                                                  |
| ------------- | --------- | ------------------------------------------------------------ | ------------------ | ------------------------------------------------------------ |
| cVersion      | propiedad |                                                              | Versión            | La versión actual de la biblioteca.                          |
| validateJSON | función   | Cadena JSON UTF-8                                            | Booleano           | Valide si una cadena es un JSON.                             |
| minifyJSON    | función   | JSON UTF-8                                                   | Cadena JSON UTF-8 | Elimina los espacios innecesarios de la cadena JSON.         |
| JSONStringify | función   | LC Array, si se fuerza el tipo de los elementos del JSON y si se formatea de forma bonita | Cadena JSON UTF-8 | Obtiene la cadena JSON de una matriz LC.                     |
| JSONParser    | función   | Cadena JSON UTF-8                                           | LC Array           | Obtiene la matriz LC de una cadena JSON.                     |

Estas son las cuatro funciones que se incluyen opcionalmente para la compatibilidad de PhotonJSON con proyectos que usan mergeJSON o FastJSON. Esperan los mismos parámetros que en sus versiones originales y en el mismo orden.

```
ArrayToJSON(), JsonToArray(), arrayFromJson() y jsonFromArray().
```

Si no desea que PhotonJSON sobrescriba las funciones anteriores, simplemente comente el código en la biblioteca PhotonJSON.

> **¿Por qué no usamos estos nombres para la biblioteca y usamos JSONStringify y JSONParser como en la API HTML5? **
>
> *Creamos esta librería para ser utilizada en un plugin que se integraré con el IDE de LiveCode y como aclaramos en la nota. Cuando se llama a una función y está en dos bibliotecas, la primera de la ruta tendrá prioridad sobre las demás. Entonces, para no interferir con otros proyectos en los que no desea usar esta biblioteca, decidimos usar esta convención de nomenclatura y no incluir las demás.*

### Copyright (C) 2020 [FerrusLogic S.A.](https://ferruslogic.com/)

