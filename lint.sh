#!/bin/bash

echo "Linting Clean Architecture..."

# Utilisation de la commande find pour rechercher tous les fichiers correspondant au modèle */app/use-cases/*.handler.ts
filesUsecases=$(find src -path "*/app/use-cases/*.ts" -type f | grep -v "/test/" | grep -v "\.spec\.ts$")
filesApp=$(find src -path "*/app/*.ts" -type f | grep -v "/test/" | grep -v "\.spec\.ts$")
filesInterface=$(find src -path "*/port/*.ts" -type f | grep -v "/test/" | grep -v "\.spec\.ts$")
filesEntity=$(find src -path "*/infra/datastore/entity/*.ts" -type f | grep -v "/test/" | grep -v "\.spec\.ts$")
filesDomain=$(find src -path "*/domain/*.ts" -type f | grep -v "/test/" | grep -v "\.spec\.ts$")
filesAppOrDomain=$(find src \( -path "*/domain/*.ts" -o -path "*/app/*.ts" \) -type f -not -path "*/test/*" -not -name "*.spec.ts")

fileCounter=0


# Vérifier si tous les fichiers se terminent par .handler.ts
for file in $filesUsecases; do
  echo "check for file name in: " $file
  if [[ "$file" != *.handler.ts ]]; then
    echo "Error: File $file does not end with .handler.ts"
    exit 1
  fi
   ((fileCounter++))
done

for file in $filesEntity; do
  echo "check for file name in: " $file
  if [[ "$file" != *.entity.ts ]]; then
    echo "Error: File $file does not end with .entity.ts"
    exit 1
  fi
   ((fileCounter++))
done

for file in $filesDomain; do
  echo "check for DDD principles in:" $file
  if grep -q -E "class.*Entity|class.*ValueObject|class.*Aggregate" "$file"; then
    echo "Error: File $file violates DDD principles in /domain."
    exit 1
  fi

  # Incrémenter le compteur de fichiers
  ((fileCounter++))
done

# Ajouter des vérifications supplémentaires ici pour les appels de framework dans /domain ou /app
for file in $filesAppOrDomain ; do
 echo "check for framework dependency in:" $file
 if grep -q "@nestjs/common" "$file"; then
   echo "Error: File $file contains a framework call, which is not allowed in /domain or /app."
   exit 1
 fi
 echo "check for librairies dependency in:" $file
  if awk '/^*from / && !/@app/' $file | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | grep .; then
     echo "Error: File $file contains an import statement that does not start with '@app', which is not allowed in /app."
     exit 1
   fi
   ((fileCounter+=2))
done

for file in $filesInterface; do
  echo "check for interface in:" $file
  if grep -q -E "class|enum" "$file" && ! grep -q "interface" "$file"; then
      echo "Error: File $file contains a class or enum, but it does not contain an interface, which is not allowed in /domain or /app."
      exit 1
  fi
   ((fileCounter++))
done

echo "Clean Architecture validation passed. $fileCounter check done."
