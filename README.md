# Mental dice

SDK Flutter for Mental Dice by Marc Antoine

## Getting Started

You need to use states_rebuilder and register a new Inject(() => Dices()) in your Injector.

To connect the dice :

Dices.i.searchDices();

to know if the device is connected :

Dices.i.device != null;

to get the status as a stream :

Dices.i.getStatus();

to get the last state of the dices :

Dices.i.getDicesState()



