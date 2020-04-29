# Termostato Intelligente via Blockchain 

### Specifica progetto

Il progetto consiste nella realizzazione un termostato intelligente integrando soluzioni hardware IoT con soluzioni software di controllo basate su Blockchain.
La fase iniziale prevede la modellazione dell'intero processo del termostato tramite modelli di coreografia dove si evidenzierà lo scambio di messaggi tra i componenti hardware e software. 
A titolo di esempio si faccia riferimento al modello sottostante dove si riporta lo scambio di messaggi tra l’utente, il termostato e il sistema di riscaldamento. 
Il modello rappresenta il punto di partenza per l’integrazione tra hardware e blokchain per tramite della  piattaforma online ChorChain (http://virtualpros.unicam.it:8080/ChorChain/), usata per gestire la logica del termostato su blockchain Ethereum. 
Il progetto dovrà prevedere una prima fase di studio dell’harware e del software da utilizzare per la realizzazione del progetto. Questo studio dovrà anche prevedere tutte le possibili interazioni fra componenti (l’idea è di partire con un sistema basato su arduino/Rasberry Pi).
Una volta definite le scelte progettuali si passerà alla sua implementazione prototipale utilizzando soluzioni software (simulatori) e una volta accertata la fattibilità, si passerà all’utilizzo dell’hardware definito durante la fase di progettazione.
L'interazione tra il termostato e la blockchain avverrà sfruttando le funzionalità già esistenti di ChorChain e, dove necessario, la creazione di nuove. In particolare, si dovrà fare uno studio preliminare sulla piattaforma, così da capire la soluzione migliore, come l’aggiunta di servizi richiamabili dal sistema IoT o la creazione di un framework ad-hoc per la comunicazione con la blockchain. 
L'obiettivo è quello di creare un applicazione  dove i dati verranno inseriti e letti dalla blockchain, che andrà ad influenzare attivamente i processi decisionali e le operazioni previste dal modello. Un esempio può essere trovato nel modello riportato di seguito, dove le operazioni di “start heating” e “stop heating” dipendono dalla temperatura emessa in precedenza. Nel nuovo sistema questo valore dovrà essere letto direttamente dalla blockchain che andrà così a influenzare l'operazione successiva.

### Steps
1. 	Analisi dei requisiti del sistema di termostato intelligente
2. 	Studio della piattaforma ChorChain per capire quali sono le funzionalità da usare già presenti  e quali possono essere aggiunte per un efficiente integrazione
3.  Analisi dell’hardware necessario
4.  Progettazione del sistema termostato intelligente
5.  Creazione del modello/i rappresentante il sistema di termostato intelligente
6. 	Realizzazione del sistema di termostato intelligente tramite simulatore
7. 	Creazione del prototipo del sistema di termostato intelligente
8. 	Deploy del sistema funzionante con hardware e validazione



### Autori
@BackCamino

@EmmanueleBollino
