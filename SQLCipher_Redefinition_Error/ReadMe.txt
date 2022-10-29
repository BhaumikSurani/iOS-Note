Solution for:- SQLCipher 4.5.2


If Use SQLCipher lib and use original "Sqlite3" in project it give error like
Redefinition of 'sqlite3_file'

If your pod lib use original sqlite3 then also get "Redefinition" error.

In this project Mix-Panel lib use "import Sqlite3" so getting this error.


For solving this error you have replace "sqlite3.h" and "sqlite3.c" in following dir.
Dir:- ./Pods/SQLCipher