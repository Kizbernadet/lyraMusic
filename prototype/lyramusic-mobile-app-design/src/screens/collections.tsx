import { useState } from "react";
import { Icon } from "../lib/icons";
import {
  AppBar,
  Art,
  Badge,
  Banner,
  Button,
  Card,
  Chip,
  Divider,
  EmptyState,
  Mosaic,
  SectionHead,
  TrackRow,
  useLyra,
} from "../lib/ui";
import { playlists, songs } from "../lib/data";
import type { Song } from "../lib/data";

/* ---------------------------------------------------------- 13 PLAYLISTS */

export function PlaylistsScreen() {
  const { go } = useLyra();
  const [view, setView] = useState<"grid" | "list">("grid");

  return (
    <div className="px-5 pb-4">
      <AppBar
        title="Playlists"
        subtitle={`${playlists.length} local playlists`}
        large
        right={
          <div className="flex gap-1">
            <button
              aria-label="Toggle view"
              onClick={() => setView(view === "grid" ? "list" : "grid")}
              className="press grid h-9 w-9 place-items-center rounded-full text-[var(--text-2)]"
            >
              <Icon name={view === "grid" ? "list" : "grid"} size={19} />
            </button>
            <button
              aria-label="Create playlist"
              onClick={() => go("createPlaylist")}
              className="press grid h-9 w-9 place-items-center rounded-full text-[var(--on-primary)]"
              style={{ background: "var(--primary)" }}
            >
              <Icon name="plus" size={18} />
            </button>
          </div>
        }
      />

      <div className="mb-4 grid grid-cols-2 gap-3">
        <Card onClick={() => go("favorites")} className="flex items-center gap-3">
          <span className="grid h-10 w-10 place-items-center rounded-[12px]" style={{ background: "var(--primary-soft)", color: "var(--primary)" }}>
            <Icon name="heart" size={18} filled />
          </span>
          <span>
            <span className="t-title block">Favorites</span>
            <span className="t-meta block text-[var(--text-2)]">38 songs</span>
          </span>
        </Card>
        <Card onClick={() => go("history")} className="flex items-center gap-3">
          <span className="grid h-10 w-10 place-items-center rounded-[12px]" style={{ background: "var(--surface-2)", color: "var(--text-2)" }}>
            <Icon name="clock" size={18} />
          </span>
          <span>
            <span className="t-title block">History</span>
            <span className="t-meta block text-[var(--text-2)]">Recently played</span>
          </span>
        </Card>
      </div>

      {view === "grid" ? (
        <div className="grid grid-cols-2 gap-x-4 gap-y-5">
          {playlists.map((p) => (
            <button key={p.id} onClick={() => go("playlistDetail")} className="press text-left">
              <Mosaic art={p.art} size="100%" radius={16} />
              <p className="t-title clamp-1 mt-2">{p.name}</p>
              <p className="t-meta text-[var(--text-2)]">{p.count} songs</p>
              <p className="t-meta text-[var(--text-3)]">{p.updated}</p>
            </button>
          ))}
        </div>
      ) : (
        <div className="space-y-1">
          {playlists.map((p) => (
            <button key={p.id} onClick={() => go("playlistDetail")} className="press flex w-full items-center gap-3 py-1.5 text-left">
              <Mosaic art={p.art} size={50} radius={12} />
              <span className="min-w-0 flex-1">
                <span className="t-title clamp-1 block">{p.name}</span>
                <span className="t-meta block text-[var(--text-2)]">
                  {p.count} songs · {p.updated}
                </span>
              </span>
              <Icon name="chevronRight" size={16} className="text-[var(--text-3)]" />
            </button>
          ))}
        </div>
      )}

      <div className="mt-5">
        <Banner
          icon="info"
          title="Playlists live on this device"
          text="A song can appear more than once in the same playlist — useful for sets and transitions."
        />
      </div>
    </div>
  );
}

/* ---------------------------------------------------------- 14 CREATE PLAYLIST */

export function CreatePlaylistScreen() {
  const { back, go, notify } = useLyra();
  const [name, setName] = useState("Sunday Archive");
  const [picked, setPicked] = useState<string[]>(["s1", "s5"]);

  const toggle = (id: string) => setPicked((p) => (p.includes(id) ? p.filter((x) => x !== id) : [...p, id]));

  return (
    <div className="flex h-full flex-col">
      <div className="px-5">
        <AppBar
          title="New playlist"
          onBack={back}
          right={
            <Button
              size="sm"
              onClick={() => {
                notify("Playlist created");
                go("playlistDetail");
              }}
            >
              Save
            </Button>
          }
        />
      </div>

      <div className="no-bar flex-1 overflow-y-auto px-5 pb-6">
        <div className="flex gap-4 pt-1">
          <button className="press relative" aria-label="Choose artwork">
            <Mosaic art={playlists[0].art} size={96} radius={18} />
            <span
              className="absolute inset-0 grid place-items-center rounded-[18px] text-white"
              style={{ background: "rgba(8,8,12,.5)" }}
            >
              <Icon name="image" size={20} />
            </span>
          </button>
          <div className="min-w-0 flex-1">
            <label className="t-label block text-[var(--text-3)]">Playlist name</label>
            <input
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="t-h3 mt-1.5 w-full border-b border-[var(--divider-strong)] bg-transparent pb-2 text-[var(--text)] outline-none focus:border-[var(--primary)]"
            />
            <p className="t-meta mt-2 text-[var(--text-3)]">
              Artwork is generated from the first songs until you choose your own.
            </p>
          </div>
        </div>

        <div className="mt-6">
          <SectionHead title={`Add songs · ${picked.length} selected`} action="Select all" />
          <div className="no-bar -mx-5 mb-3 flex gap-2 overflow-x-auto px-5">
            <Chip active>All songs</Chip>
            <Chip>Favorites</Chip>
            <Chip>Recently added</Chip>
            <Chip>Albums</Chip>
          </div>
          <div className="space-y-0.5">
            {songs.map((s) => {
              const on = picked.includes(s.id);
              return (
                <TrackRow
                  key={s.id}
                  song={s}
                  dense
                  onPlay={() => toggle(s.id)}
                  trailing={
                    <button
                      aria-label={on ? "Remove" : "Add"}
                      onClick={() => toggle(s.id)}
                      className="press grid h-7 w-7 place-items-center rounded-full border"
                      style={{
                        background: on ? "var(--primary)" : "transparent",
                        borderColor: on ? "transparent" : "var(--divider-strong)",
                        color: on ? "var(--on-primary)" : "var(--text-3)",
                      }}
                    >
                      <Icon name={on ? "check" : "plus"} size={13} />
                    </button>
                  }
                />
              );
            })}
          </div>
        </div>
      </div>

      <div className="border-t border-[var(--divider)] bg-[var(--bg)] px-5 py-3">
        <div className="flex gap-2">
          <Button variant="secondary" full onClick={back}>
            Cancel
          </Button>
          <Button
            full
            onClick={() => {
              notify("Playlist created");
              go("playlistDetail");
            }}
          >
            Create playlist
          </Button>
        </div>
      </div>
    </div>
  );
}

/* ---------------------------------------------------------- 15 PLAYLIST DETAIL */

export function PlaylistDetailScreen() {
  const { back, go, play, openSheet, notify } = useLyra();
  const pl = playlists[0];
  const [list, setList] = useState<Song[]>([songs[0], songs[4], songs[6], songs[0], songs[8], songs[2]]);
  const [drag, setDrag] = useState<number | null>(null);
  const [over, setOver] = useState<number | null>(null);

  const move = (from: number, to: number) => {
    if (to < 0 || to >= list.length || from === to) return;
    const next = [...list];
    const [row] = next.splice(from, 1);
    next.splice(to, 0, row);
    setList(next);
  };

  return (
    <div className="pb-4">
      <div className="relative">
        <div className="absolute inset-0 h-[230px] overflow-hidden">
          <Art src={pl.art[0]} size="fill" radius={0} className="scale-[1.4] opacity-55 blur-[42px]" />
          <div className="absolute inset-0" style={{ background: "linear-gradient(180deg,transparent,var(--bg))" }} />
        </div>
        <div className="relative px-5">
          <AppBar
            title=""
            transparent
            onBack={back}
            right={
              <button aria-label="Playlist options" onClick={() => openSheet("menu")} className="press grid h-9 w-9 place-items-center rounded-full text-[var(--text)]">
                <Icon name="more" size={20} />
              </button>
            }
          />
          <div className="flex flex-col items-center pt-1 text-center">
            <Mosaic art={pl.art} size={156} radius={22} />
            <h1 className="t-h1 mt-4">{pl.name}</h1>
            <p className="t-meta mt-1 text-[var(--text-2)]">
              {list.length} songs · 1 h 42 min · local playlist
            </p>
            <div className="mt-4 flex w-full gap-2">
              <Button full icon="play" onClick={() => { play(list[0]); go("player"); }}>
                Play
              </Button>
              <Button full variant="secondary" icon="shuffle" onClick={() => { setList([...list].reverse()); play(list[2]); go("player"); }}>
                Shuffle
              </Button>
            </div>
          </div>
        </div>
      </div>

      <div className="mt-6 px-5">
        <div className="mb-1 flex items-center justify-between">
          <SectionHead title="Songs" />
          <span className="t-meta -mt-3 text-[var(--text-3)]">Drag to reorder</span>
        </div>

        <ul className="space-y-0.5">
          {list.map((s, i) => (
            <li
              key={`${s.id}-${i}`}
              draggable
              onDragStart={() => setDrag(i)}
              onDragOver={(e) => {
                e.preventDefault();
                setOver(i);
              }}
              onDrop={() => {
                if (drag !== null) move(drag, i);
                setDrag(null);
                setOver(null);
              }}
              onDragEnd={() => {
                setDrag(null);
                setOver(null);
              }}
              className={`flex items-center gap-1 rounded-[var(--r-md)] transition-all ${
                over === i && drag !== null ? "bg-[var(--primary-soft)] ring-1 ring-[var(--primary)]" : ""
              } ${drag === i ? "opacity-40" : ""}`}
            >
              <span className="cursor-grab pl-0.5 text-[var(--text-3)]">
                <Icon name="grip" size={17} />
              </span>
              <div className="min-w-0 flex-1">
                <TrackRow
                  song={s}
                  dense
                  onPlay={() => {
                    play(s);
                    go("player");
                  }}
                  onMenu={() => openSheet("menu")}
                  trailing={
                    i === 3 ? (
                      <div className="flex items-center gap-1">
                        <Badge>Repeat entry</Badge>
                        <button aria-label="More" onClick={() => openSheet("menu")} className="press grid h-9 w-8 place-items-center text-[var(--text-3)]">
                          <Icon name="more" size={17} />
                        </button>
                      </div>
                    ) : undefined
                  }
                />
              </div>
            </li>
          ))}
        </ul>

        <div className="mt-4 flex gap-2">
          <Button variant="secondary" size="sm" icon="plus" full onClick={() => go("createPlaylist")}>
            Add songs
          </Button>
          <Button variant="secondary" size="sm" icon="edit" full onClick={() => notify("Rename playlist")}>
            Edit details
          </Button>
        </div>
      </div>
    </div>
  );
}

/* ---------------------------------------------------------- 16 FAVORITES */

export function FavoritesScreen() {
  const { back, go, play, openSheet, toggleFav, notify } = useLyra();
  const [list, setList] = useState<Song[]>([songs[0], songs[4], songs[8], songs[7], songs[5], songs[6]]);

  return (
    <div className="px-5 pb-4">
      <AppBar
        title="Favorites"
        subtitle="Songs only"
        large
        onBack={back}
        right={
          <button aria-label="Sort" className="press grid h-9 w-9 place-items-center rounded-full text-[var(--text-2)]">
            <Icon name="sort" size={19} />
          </button>
        }
      />
      {list.length === 0 ? (
        <div className="pt-6">
          <EmptyState
            icon="heart"
            title="No favorites yet"
            text="Tap the heart on any song to keep it here. Favorites always stay on your device."
            action="Browse library"
            onAction={() => go("songs")}
          />
        </div>
      ) : (
        <>
          <div className="mb-4 flex items-center gap-2">
            <Button size="sm" icon="play" onClick={() => go("player")}>
              Play
            </Button>
            <Button size="sm" variant="secondary" icon="shuffle" onClick={() => go("player")}>
              Shuffle
            </Button>
            <span className="t-meta ml-auto text-[var(--text-3)]">{list.length} songs</span>
          </div>
          <div className="space-y-0.5">
            {list.map((s, i) => (
              <TrackRow
                key={`${s.id}-${i}`}
                song={s}
                index={i + 1}
                onPlay={() => {
                  play(s);
                  go("player");
                }}
                onMenu={() => openSheet("menu")}
                trailing={
                  <div className="flex items-center gap-0.5">
                    <span className="t-tech text-[var(--text-3)]">{s.duration}</span>
                    <button
                      aria-label="Remove from favorites"
                      onClick={() => {
                        toggleFav(s.id);
                        setList(list.filter((_, x) => x !== i));
                        notify("Removed from Favorites");
                      }}
                      className="press grid h-9 w-9 place-items-center rounded-full text-[var(--primary)]"
                    >
                      <Icon name="heart" size={17} filled />
                    </button>
                  </div>
                }
              />
            ))}
          </div>
          <div className="mt-5">
            <Banner icon="info" title="Favorites are for songs" text="Albums and artists are browsed from the Library instead." />
          </div>
        </>
      )}
    </div>
  );
}

/* ---------------------------------------------------------- 17 HISTORY */

export function HistoryScreen() {
  const { back, play, go, openSheet } = useLyra();
  const groups: [string, Song[]][] = [
    ["Today", [songs[0], songs[8], songs[4]]],
    ["Yesterday", [songs[5], songs[1]]],
    ["This week", [songs[6], songs[7], songs[2]]],
    ["Earlier", [songs[3]]],
  ];

  return (
    <div className="px-5 pb-4">
      <AppBar
        title="History"
        subtitle="Recently played"
        large
        onBack={back}
        right={
          <button aria-label="Clear history" className="press grid h-9 w-9 place-items-center rounded-full text-[var(--text-2)]">
            <Icon name="trash" size={18} />
          </button>
        }
      />
      <div className="space-y-6 pt-1">
        {groups.map(([label, items]) => (
          <section key={label}>
            <div className="mb-2 flex items-center gap-3">
              <p className="t-label text-[var(--text-3)]">{label}</p>
              <Divider />
            </div>
            <div className="space-y-0.5">
              {items.map((s, i) => (
                <TrackRow
                  key={`${label}-${s.id}-${i}`}
                  song={s}
                  dense
                  onPlay={() => {
                    play(s);
                    go("player");
                  }}
                  onMenu={() => openSheet("menu")}
                  trailing={<span className="t-tech text-[var(--text-3)]">{["21:04", "20:38", "19:12", "23:51", "22:07", "—", "—", "—"][i] ?? "—"}</span>}
                />
              ))}
            </div>
          </section>
        ))}
      </div>
      <p className="t-meta mt-7 text-center text-[var(--text-3)]">
        History is stored locally and never leaves your device.
      </p>
    </div>
  );
}
