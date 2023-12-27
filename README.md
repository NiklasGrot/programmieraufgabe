# MasterProgrammieraufgabe 

Dieses Programm wurde für die Bewerbung auf den Masterstudiengang Digital Reality an der HAW-Hamburg von Niklas Grotzeck geschrieben. Die Aufgabenstellung lässt sich hier finden: 
https://www.haw-hamburg.de/fileadmin/Studium/StgInfo/PDF/DR_Programmieraufgabe.pdf 

Das Endergebnis ist auf dieser Webiste zu sehen: https://programmieraufgabe-niklas-grotzeck.fly.dev/ 

## weitere Informationen:
  Ich habe mein Programm als Webapplication mithilfe der Programmiersprache Elixir und dem Webframework Phoenix geschrieben. Viele der vorliegenden Dateien enthalten die nötige Infrastruktur für das Phoenix-Framework. Die Dateien die den relevanten Code für die Umsetzung der Aufgabenstellung, sowie Logik und Darstellung des UI finden sich in diesen Ordnern: 

  - [`lib/master_programmieraufgabe/math_utils.ex`](lib/master_programmieraufgabe/math_utils.ex) (Enthält alle benötigten Mathematischen Funktionen)
  - [`lib/master_programmieraufgabe_web/live/triangle_live.ex`](lib/master_programmieraufgabe_web/live/triangle_live.ex) (Enthält Alle UI Komponenten und ihre Logik)
  - [`lib/master_programmieraufgabe/canvas_drawer.ex`](lib/master_programmieraufgabe/canvas_drawer.ex) (Enthält Module zum Zeichen von Punkten und Linien auf ein Canvas)

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
