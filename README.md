# Agenda Fatec

Agenda acadêmica em Flutter para Android. Na aba Semana, use + para cadastrar uma prova, trabalho ou evento. Toque em um cartão para editar. O calendário marca os dias com compromissos.

## Executar

Com um emulador Android aberto ou celular conectado, execute:

```sh
flutter pub get
flutter run
```

## Dados

O SQLite guarda os registros na tabela atividades do arquivo agenda_fatec.db. Os tópicos de revisão ficam na coluna topicos (JSON). Para consultar os registros em um emulador Android API 26 ou superior, abra App Inspection no Android Studio, selecione o processo do app e abra Database Inspector.

