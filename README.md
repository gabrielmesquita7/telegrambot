# Monitoramento de Carga de CPU via Bot do Telegram

Este projeto permite monitorar a carga da CPU do servidor local e enviar relatórios a um grupo ou a um chat no Telegram, utilizando a API do Telegram. O bot envia relatórios da carga da CPU a cada 2 horas e, se os valores ultrapassarem um limite de segurança definido, também envia um alerta.

## Pré-requisitos

Antes de iniciar, certifique-se de que você tem:
1. **Uma conta no Telegram** e um **bot criado**.
2. **Acesso ao terminal do servidor** ou máquina onde o script será executado.
3. **`curl` e `bc` instalados** no sistema para fazer requisições à API do Telegram e cálculos de ponto flutuante.

### Passo 1: Criar o Bot no Telegram

1. Abra o Telegram e procure por `BotFather`.
2. Envie o comando `/newbot` e siga as instruções para criar um novo bot.
3. O `BotFather` vai gerar um `TOKEN` para o seu bot. Guarde-o, pois você vai precisar dele no próximo passo.

### Passo 2: Obter o ID do Chat ou Grupo no Telegram

1. Adicione o bot ao grupo ou envie uma mensagem diretamente a ele.
2. Use o seguinte link no seu navegador para obter as informações das mensagens mais recentes:
- https://api.telegram.org/bot<SEU_BOT_TOKEN>/getUpdates
- **Substitua `<SEU_BOT_TOKEN>`** pelo token que você recebeu do `BotFather`.
3. No JSON retornado, procure pelo campo `chat.id`, que será o `ID` do grupo ou usuário para o qual o bot deve enviar as mensagens.

### Passo 3: Instalar Dependências

No servidor ou máquina local onde você vai monitorar a CPU, instale as dependências necessárias:

```bash
sudo apt-get update
sudo apt-get install curl bc
```
### Passo 4: Configurar o Script de Monitoramento

Crie um arquivo chamado `monitorar_cpu.sh` e insira o seguinte conteúdo:

```bash
#!/bin/bash

# Variáveis de configuração
BOT_TOKEN="seu_bot_token_aqui"
CHAT_ID="id_do_chat_ou_grupo_aqui"
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
```

### Passo 5: Configurar as Variáveis
- `BOT_TOKEN`: Substitua "seu_bot_token_aqui" pelo token que você recebeu do BotFather.
- `CHAT_ID`: Substitua "id_do_chat_ou_grupo_aqui" pelo ID do chat ou grupo que você obteve no Passo 2.
- `LIMITE_ALERTA`: Defina o limite de alerta da CPU para o seu servidor (o valor padrão é 2.0).

### Passo 6: Tornar o Script Executável

Torne o script executável rodando o seguinte comando:

```bash
chmod +x script.sh
```

### Passo 7: Executar o Script

```bash
./script.sh
```
