# KiCad libraries for EE3580

`lab_components/` is the KiCad symbol and footprint library for the components in the EE3580 lab kit,
used for the PCB laboratory (Lab 5).

| File | Contents |
|---|---|
| `lab_components.kicad_sym` | Symbols: ATtiny85, Arduino Uno R3 shield, buzzer, speaker, LED, button, resistors (220 Ω, 1 kΩ, 10 kΩ), capacitors (100 nF, 1 µF), 10 kΩ potentiometer, NTC thermistor, NPN transistor, connectors and programming headers |
| `lab_components.pretty/` | The matching footprints (`.kicad_mod`) |

## Installing in KiCad

1. Download or clone this repository.
2. Symbols: in KiCad, open **Preferences → Manage Symbol Libraries**, and add
   `lab_components.kicad_sym` with the nickname **`lab_components`**.
3. Footprints: open **Preferences → Manage Footprint Libraries**, and add the folder
   `lab_components.pretty` with the nickname **`lab_components`**.

Use exactly the nickname `lab_components`: the symbols refer to their footprints as
`lab_components:<name>`, so the footprints are only found under that nickname.

## Arduino boards

For footprints of other Arduino boards, use the third-party
[arduino-kicad-library](https://github.com/Alarm-Siren/arduino-kicad-library) by Nicholas Parks Young
(CC BY-SA 4.0). It is not included here.
