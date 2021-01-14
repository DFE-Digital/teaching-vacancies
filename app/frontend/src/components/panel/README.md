# Panel component

Javascript component that is used to toggle a class on a container using a toggle control. An example of this could be a container that toggles a class to hide or show it. A state is stored in browser LocalStorage (if available) and this is stored using the componentKey in the key/value entry. componentKey would typically be the name of the parent component that has the container and control within it.

## Usage

Import the script to where you want to use it:

```javascript
import { togglePanel } from 'path/to/panel';
```

Panel functionality can then be activated:

```javascript
togglePanel(options);
```

## Options

An Object consisting of the following key/values.

* __componentKey__ key to save state in LocalStorage __String__
* __container__ HTML DOM live element __Object__
* __defaultState__ default state string stored in localStorage __String__
* __hideText__ text for toggleControl __String__
* __onToggleHandler__ callback after panel is toggled __Function__
* __onClosedHandler__ callback after panel is closed __Function__
* __onOpenedHandler__ callback after panel is opened __Function__
* __showText__ text for toggleControl __String__
* __toggleClass__ className toggled on container __String__
* __toggleControl__ HTML DOM live element __Object__
