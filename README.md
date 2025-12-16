# Manual d'ús

## Usuari
Com a usuari, tenim  un compte d'usuari en el sistema, previament creat pel professor, així com una contrasenya.
Es tracta d'iniciar sessió a través de ssh

``` 
ssh usuari@10.0.3.250 

```
En el directori personal ('/home/alumnes/usuari') es crea per defecte una carpeta personal

## Professors

Com a professors, tenim  un compte d'usuari en el sistema, al directori /home  previament creat per l'administrador, així com una contrasenya.
Es tracta d'iniciar sessió a través de ssh:
``` 
ssh usuari@10.0.3.250 

```
### Scripts de creació de projecte

```
create_teacher_project.sh  <professor> <projecte>
```

Es genera una carpeta amb el nom del projecte al directori /home
Es genera una línia al fitxer de zona del DNS,
El DNS nameserver principal ha de ser 10.0.3.250.
El FQDN creat és el de http://projecte.teacher.fpnuria.net
