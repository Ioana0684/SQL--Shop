# Tema SQL – Baza de date magazin (MySQL)
Acest repo conține scriptul **magazin.sql** care:
- creează schema `magazin`
- definește tabelele: `Clienti`, `Produse`, `Comenzi`, `DetaliiComanda`
- adaugă indici, view (`V_TotalComenzi`), trigger (`trg_update_stoc`) și procedură (`TotalCheltuit`)
- inserează date de test (seed)
- include interogările cerute (agregări, join-uri, subinterogări)

## Cum rulezi
1. MySQL 8.0+ recomandat.
2. Deschide `magazin.sql` în MySQL Workbench.
3. Rulează scriptul cap-coadă (sau pe blocuri, în ordine).

### Teste rapide
```sql
USE magazin;
SELECT * FROM Comenzi ORDER BY data_comanda DESC;
SELECT * FROM V_TotalComenzi;
CALL TotalCheltuit(1);
