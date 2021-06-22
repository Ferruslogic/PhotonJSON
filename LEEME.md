# PhotonJSON
[Reading in English](README.md)

Biblioteca de LiveCode scripts para trabajar con JSON, escrito en livecode-script y sin el uso de externos.

En esta biblioteca, convergen las ideas de muchos desarrolladores que crearon soluciones como esta en LiveCode y en otros lenguajes de programaci�n. Aunque existen varias bibliotecas para trabajar con JSON en LiveCode. Nos planteamos un reto personal, crear nuestra propia versi�n para lo cual tomamos como base el gran trabajo realizado por Bob Hall en la librer�a FastJSON. Necesit�bamos una biblioteca como FastJSON y con la velocidad del mergJSON de Mount Goulding. As� que empezamos a escribir PhotonJSON usando las ideas y el c�digo de FastJSON como base, aunque en algunos casos reescribimos por completo los algoritmos.



## Mejoras de PhotonJSON.

En PhotonJSON, se logr� cierto grado de optimizaci�n en los procesos de an�lisis de un JSON. Por tanto, la librer�a tiene un rendimiento muy cercano al obtenido en mergJSON. Sin olvidar que este �ltimo hace uso de un externo que procesa a un nivel menor que LiveCode y por tanto es un poco m�s r�pido. Estas son algunas de las mejoras que encontramos en PhotonJSON.
1. Convierta un JSON en un Array LC en un tiempo menor, igual o muy cercano al de mergJSON.
2. Al convertir un Array LC  a JSON, puede especificar si el JSON tiene un formato bonito.
3. Se agreg� una funci�n de formato agradable y otra para minimizar los JSON existentes.



## C�mo usar PhotonJSON

Para utilizar PhotonJSON en su escritorio o aplicaciones m�viles solo tiene que cargar la biblioteca

```
start using stack"PhotonJSON"
```

Si va a utilizar PhotonJSON en su aplicaci�n de servidor, debe crear un archivo de texto sin formato con la extensi�n .lc y copiar el script de la pila PhotonJSON a este archivo sin incluir la primera l�nea (script "PhotonJSON").

```
<? lc ... el script de la pila "PhotonJSON" ...?>
```

Ya tenemos PhotonJSON integrado en nuestro proyecto. Entonces, podemos acceder a todas las funciones y propiedades de la biblioteca.



> **NOTA**
>
> *Antes de continuar, aclaremos que en LiveCode si dos bibliotecas tienen una funci�n con el mismo nombre. Si se llama a esta funci�n desde cualquier otro lado del c�digo, se ejecutar� la de la �ltima biblioteca que se llam�, es decir, la primera en la ruta del mensaje.*



PhotonJSON tiene 5 funciones y una propiedad p�blica que se puede acceder a ellas desde otro script. Tambi�n integra 4 funciones para compatibilidad con proyectos que usan otras bibliotecas y quieren comenzar a usar esta. Tenga en cuenta la nota anterior.

| Nombre        | Tipo      | Par�metro                                                    | Devoluciones       | Descripci�n                                                  |
| ------------- | --------- | ------------------------------------------------------------ | ------------------ | ------------------------------------------------------------ |
| cVersion      | propiedad |                                                              | Versi�n            | La versi�n actual de la biblioteca.                          |
| validateJSON  | funci�n   | Cadena JSON UTF-8                                            | Booleano           | Valide si una cadena es un JSON.                             |
| beautifyJSON  | funci�n   | Cadena JSON UTF-8                                            | Cadena JSON UTF-8  | Formatea una cadena JSON de una manera m�s agradable a la vista. |
| minifyJSON    | funci�n   | JSON UTF-8                                                   | Cadena JSON  UTF-8 | Elimina los espacios innecesarios de la cadena JSON.         |
| JSONStringify | funci�n   | LC Array, si se fuerza el tipo de los elementos del JSON y si se formatea de forma bonita | Cadena JSON  UTF-8 | Obtiene la cadena JSON de una matriz LC.                     |
| JSONParser    | funci�n   | Cadena JSON  UTF-8                                           | LC Array           | Obtiene la matriz LC de una cadena JSON.                     |




Estas son las cuatro funciones que se incluyen opcionalmente para la compatibilidad de PhotonJSON con proyectos que usan mergeJSON o FastJSON. Esperan los mismos par�metros que en sus versiones originales y en el mismo orden.


```
ArrayToJSON(), JsonToArray(), arrayFromJson() y jsonFromArray().
```

Si no desea que PhotonJSON sobrescriba las funciones anteriores, simplemente comente el c�digo en la biblioteca PhotonJSON.



> **�Por qu� no usamos estos nombres para la biblioteca y usamos JSONStringify y JSONParser como en la API HTML5? **
>
> *Creamos esta librer�a para ser utilizada en un plugin que se integrar� con el IDE de LiveCode y como aclaramos en la nota. Cuando se llama a una funci�n y est� en dos bibliotecas, la primera de la ruta tendr� prioridad sobre las dem�s. Entonces, para no interferir con otros proyectos en los que no desea usar esta biblioteca, decidimos usar esta convenci�n de nomenclatura y no incluir las dem�s.*



### Copyright (C) 2020 [FerrusLogic S.A.](https://ferruslogic.com/)

