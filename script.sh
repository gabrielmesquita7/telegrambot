#!/bin/bash

# Variáveis de configuração
BOT_TOKEN=7287705848:AAHCCI2xIsXlull2UD8jLwGX0UddAOcTQfs
CHAT_ID=-1002383700689
LIMITE_ALERTA=2.0  # Defina o limite de carga média para disparar o alerta

function enviar_mensagem {
    local mensagem=$1
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$mensagem"
}

function check_cpu_load {
    LOAD_1=$(cat /proc/loadavg | awk '{print $1}')
    LOAD_5=$(cat /proc/loadavg | awk '{print $2}')

    MENSAGEM="Relatório de Carga da CPU:
    - Último minuto: $LOAD_1
    - Últimos 5 minutos: $LOAD_5"

    if (( $(echo "$LOAD_5 > $LIMITE_ALERTA" | bc -l) )); then
        ALERTA="⚠️ ALERTA: Carga da CPU nos últimos 5 minutos ultrapassou o limite de segurança! (Limiar: $LIMITE_ALERTA)"
        MENSAGEM="$MENSAGEM\n\n$ALERTA"
    fi

    enviar_mensagem "$MENSAGEM"
}

while true; do
    check_cpu_load
    sleep 2h
done
