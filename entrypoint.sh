#!/bin/bash
set -e

: '
{
  "success" : true,
  "directory" : "/opt/e-SUS",
  "version" : "5.3.19",
  "production" : true,
  "customDatabase" : true,
  "databaseUrl" : "jdbc:postgresql://db:5432/esus",
  "databaseUsername" : "postgres",
  "databasePassword" : "pass",
  "jreVersion" : "17.0.10-linux_x64",
  "jreDirectory" : "/opt/e-SUS/jre/17.0.10-linux_x64",
  "webserverVersion" : "5.3.19",
  "webserverDirectory" : "/opt/e-SUS/webserver"
}
'

# Se o JAR não estiver presente na imagem, baixa em tempo de execução usando variáveis de ambiente
if [ -n "$FILENAME" ]; then
  if [ -z "$JAR_FILENAME" ]; then
    JAR_FILENAME=$(basename "$FILENAME")
  fi
  if [ ! -f "/var/www/html/$JAR_FILENAME" ]; then
    echo ">> Baixando pacote: $FILENAME -> /var/www/html/$JAR_FILENAME"
    wget -O "/var/www/html/$JAR_FILENAME" "$FILENAME"
  fi
fi

# Verifica se o sistema já foi instalado pela conferência da existência de um arquivo /etc/pec.config, caso não exista, instalar
if [ ! -f /etc/pec.config ]; then
    echo ">> Sistema ainda não foi instalado. Instalando..."
    echo ">> Gerando certificado com CertMgr e instalando o sistema..."
    chmod +x ./install.sh
    ./install.sh
fi

# Verifica existe um /etc/pec.config e se a instalação está em sucesso, caso sim, não instala. a estrutura do pec.config no início do arquivo
if [ -f "/etc/pec.config" ]; then
  # Lê o conteúdo do arquivo /etc/pec.config
  config=$(cat /etc/pec.config)
  
  # Verifica se a instalação foi bem-sucedida
  # Se a instalação foi bem-sucedida, o campo "success" deve ser true
  if echo "$config" | grep -q "\"success\" : true"; then
    # Inicie a aplicação principal
    echo ">> Iniciando aplicação principal (background) e exibindo logs..."
    /opt/e-SUS/webserver/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 &
    SERVER_PID=$!
    # Exibe logs do servidor no console (varias tentativas/locais)
    (
      try_tail() {
        for f in \
          "/opt/e-SUS/webserver/standalone/log/server.log" \
          "/opt/e-SUS/webserver/log/server.log" \
          "/opt/e-SUS/webserver/pec.log"; do
          if [ -f "$f" ] && [ -s "$f" ]; then
            echo ">> Tailing logs: $f"
            exec tail -F "$f"
          fi
        done
        # Descobrir qualquer log não vazio
        found=$(find /opt/e-SUS/webserver -maxdepth 4 -type f -name "*.log" -size +0c 2>/dev/null | head -n1)
        if [ -n "$found" ]; then
          echo ">> Tailing logs: $found"
          exec tail -F "$found"
        fi
        # Fallback: stdout do processo
        if [ -e "/proc/$SERVER_PID/fd/1" ]; then
          echo ">> No log file found yet. Streaming process stdout."
          exec cat "/proc/$SERVER_PID/fd/1"
        fi
      }
      # Tente repetir por algum tempo até aparecer arquivo de log
      for i in $(seq 1 30); do
        try_tail
        sleep 2
      done
    ) &
    wait $SERVER_PID
  else
    # Se a instalação não foi bem-sucedida, exiba uma mensagem de erro
    echo ">> Erro: Instalação não foi bem-sucedida."
    echo ">> Tentando reinstalar sistema..."
    chmod +x ./install.sh
    ./install.sh
    exit 1
  fi
fi

echo ">> Iniciando aplicação principal (background) e exibindo logs..."
/opt/e-SUS/webserver/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 &
SERVER_PID=$!
(
  try_tail() {
    for f in \
      "/opt/e-SUS/webserver/standalone/log/server.log" \
      "/opt/e-SUS/webserver/log/server.log" \
      "/opt/e-SUS/webserver/pec.log"; do
      if [ -f "$f" ] && [ -s "$f" ]; then
        echo ">> Tailing logs: $f"
        exec tail -F "$f"
      fi
    done
    found=$(find /opt/e-SUS/webserver -maxdepth 4 -type f -name "*.log" -size +0c 2>/dev/null | head -n1)
    if [ -n "$found" ]; then
      echo ">> Tailing logs: $found"
      exec tail -F "$found"
    fi
    if [ -e "/proc/$SERVER_PID/fd/1" ]; then
      echo ">> No log file found yet. Streaming process stdout."
      exec cat "/proc/$SERVER_PID/fd/1"
    fi
  }
  for i in $(seq 1 30); do
    try_tail
    sleep 2
  done
) &
wait $SERVER_PID