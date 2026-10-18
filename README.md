# faculty-schedule-variant6

Лабораторные работы по хранилищам данных.

- `01_3nf.sql` — модель в третьей нормальной форме (схема `nf3`, 10 таблиц)
- `02_data_vault.sql` — модель Data Vault (схема `dv`, 21 таблица: 7 хабов, 5 линков, 9 саттелитов)
- `03_seed.sql` — тестовые данные для 3НФ
- `erd_3nf.png`, `erd_dv.png` — схемы баз данных

Проверено в PostgreSQL 17:

```
psql -f 01_3nf.sql -f 02_data_vault.sql -f 03_seed.sql
```
