#!/bin/bash
set -e

host="db"
port="5432"
user="postgres"

echo "Aguardando o serviço de banco de dados ($host:$port)..."

# Espera o Postgres ficar pronto para conexões usando pg_isready
until PGPASSWORD="$POSTGRES_PASSWORD" pg_isready -h "$host" -p "$port" -U "$user"
do
  echo "Aguardando o Postgres iniciar..."
  sleep 1
done

echo "Verificando dependências do Ruby..."
# Garante que as gems estejam instaladas/verificadas (boa prática para volumes)
bundle check || bundle install

# Prepara o Banco de Dados (db:create, db:migrate, db:seed)
echo "Preparando o Banco de Dados (db:prepare)..."
bundle exec rails db:prepare

# Executa o comando principal do container (CMD)
echo "Iniciando o comando principal: $@"
exec "$@"