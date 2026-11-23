# Projekt gry w Godot 4

Gra 2D, top-down, pixel art. Silnik: Godot 4.5 (GDScript, Forward Plus). Autor tworzy grę sam.
Katalog tego pliku (`sandbox`) jest głównym katalogiem projektu (`res://`), tu leży `project.godot`.

## Jak ze mną pracować

- Odpowiadaj po polsku, krótko i konkretnie.
- Przy poprawkach kodu podawaj: **plik**, **funkcję/miejsce** i **co zamienić na co**. Bez długich wstępów.
- Nie zmieniaj plików projektu, dopóki nie poproszę. Zaproponuj zmianę, a ja wprowadzę ją w edytorze.
- Nie używaj gita. Czytaj kod wyłącznie z tego katalogu.
- Nie usuwaj starych scen, skryptów ani assetów bez pytania. Część to porzucone elementy (questy, niektóre levele), ale mogą mieć ukryte powiązania.
- Przed zaproponowaniem zmiany przeczytaj aktualną wersję pliku, bo kod zmienia się na bieżąco.

## Mapa projektu

- `00_Globals` – managery (autoload), magistrala wiadomości, efekty globalne
- `Enemies` – wrogowie. Każdy typ ma własny podkatalog (Goblin, ArmoredGoblin, Orc, Slime, Zombie, SkeletonArcher, ShootingEnemy, Boss1). `Enemies/Scripts` zawiera wspólny `enemy.gd`, `pathfinder.gd` i maszynę stanów, a `Enemies/Scripts/states` stany wrogów
- `GeneralNodes` – węzły pomocnicze: HurtBox, HitBox, SavePoint, PersistentDataHandler, EnemySpawner, TriggerArea, pogoda i mgła
- `GUI` – HUD, menu pauzy, ekwipunek, dialogi, sklep, notatki, ołtarz, przejścia scen
- `Interactables` – obiekty używalne i pociski: strzała (`arrow`), włócznia/strzała łucznika (`spear`), bomba, hak (`grapple_post`), skrzynie, drzwi (`Dungeon`), ołtarz, dialogi, sklepikarz
- `items` – przedmioty, pickupy, dane przedmiotów
- `Levels` – poziomy (`Area01`, `Dungeon02`), przejścia między poziomami, `player_spawn.tscn`, muzyka
- `npc` – postacie niezależne
- `Player` – gracz: `player.tscn`, `Scripts` (stany gracza, umiejętności w `Scripts/abilities`), `Sprites`, `Audio`
- `Props` – rekwizyty
- `quests` – system questów (`quests/scripts/global_quest_manager.gd`)
- `shaders and materials` – shadery i materiały
- `Tile Maps` – zasoby TileMap
- `title_scene` – scena startowa i splash screen
- `tutorial_udemy` – pozostałości po tutorialu z Udemy

## Autoloady (project.godot)

`AudioManager`, `LevelManager`, `PlayerHud`, `PlayerManager`, `SceneTransition`, `SaveManager`, `PauseMenu`, `DialogSystem`, `QuestManager`, `EffectManager`, `ShopMenu`, `NotesMenu`, `Messages`, `AltarMenu`.

- `PlayerManager.player` to aktualny gracz, `PlayerManager.INVENTORY_DATA` to ekwipunek.
- `SaveManager.current_save` to słownik zapisu, zapisywany do `user://save.sav` jako JSON. Nowe pola dodawaj z domyślną wartością i odczytuj przez `.get()`, żeby stare zapisy nie powodowały błędów.
- Klucze zapisu stanu scen zależą od `scene_file_path`. Zmiana nazwy lub przeniesienie sceny może zgubić zapisane dane.
- `Messages` to magistrala sygnałów między systemami.

## Konwencje kodu

- Gracz ma maszynę stanów z metodami `Enter`, `Exit`, `Process`, `Physics`, `HandleInput` (pisane wielką literą). Skrypty w `Player/Scripts/state_*.gd`.
- Wrogowie mają `EnemyStateMachine` z metodami `init`, `enter`, `exit`, `process`, `physics` (małą literą), stany w `Enemies/Scripts/states/enemy_state_*.gd`.
- Wrogowie używają `Pathfinder` (context steering, 8 RayCast2D) tworzonego przez stany `Chase`, `Flee` i `Shoot`.
- Animacje gracza i wrogów wywołuje się jako `nazwa + "_" + kierunek` (`down`, `up`, `side`). Kierunek w lewo to odbicie sprite'a przez `scale.x`.

## Warstwy kolizji (2D physics)

1 Player · 2 PlayerHurt · 3 PlayerInteract · 4 GrappleObstacles · 5 Walls · 6 GrapplePoints · 7 EnemyBoundary · 8 AbyssBoundary · 9 Enemy · 10 MountainWalls

Pociski (strzała gracza, strzała łucznika) giną po wejściu w warstwę 5.

## Wejście

Akcje: `up`, `down`, `left`, `right`, `attack`, `dash`, `interact`, `ability`, `switch_ability`, `aim`, `ability_trigger`, `heal`, `pause`. Gra obsługuje klawiaturę z myszą i kontroler. Celowanie na kontrolerze (`aim` i `ability_trigger`) przechodzi przez stan `State_Aim`, a na myszy przez `State_Bow`.

## Ekran

Rozdzielczość logiczna 480×270, okno 1920×1080, rozciąganie `canvas_items`. Filtr tekstur: nearest (pixel art). Włączona jest interpolacja fizyki i przyciąganie wierzchołków do pikseli.
