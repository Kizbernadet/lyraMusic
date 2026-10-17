import { useState } from "react";
import { Icon } from "../lib/icons";
import {
  Art,
  Badge,
  Banner,
  Button,
  Chip,
  EmptyState,
  EqBars,
  IconBtn,
  Scrubber,
  SectionHead,
  Sheet,
  TrackRow,
  useLyra,
} from "../lib/ui";
import { lyrics as lyricData, songs } from "../lib/data";
import type { Song } from "../lib/data";

function Ambient({ src, seed = 0 }: { src?: string | null; seed?: number }) {
  return (
    <div className="pointer-events-none absolute inset-0 overflow-hidden">
      <Art src={src} size="fill" radius={0} seed={seed} className="absolute inset-0 scale-[1.6] opacity-60 blur-[64px]" />
      <div
        className="absolute inset-0"
        style={{
          background:
            "linear-gradient(180deg, color-mix(in srgb,var(--bg) 62%,transparent) 0%, color-mix(in srgb,var(--bg) 86%,transparent) 48%, var(--bg) 100%)",
        }}
      />
    </div>
  );
}

/* ---------------------------------------------------------- 11 FULL PLAYER */

export function PlayerScreen() {
  const { back, go, openSheet, playing, setPlaying, current, favs, toggleFav, notify } = useLyra();
  const [pos, setPos] = useState(44);
  const [repeat, setRepeat] = useState<"off" | "all" | "one">("all");
  const [shuffle, setShuffle] = useState(false);
  const fav = favs.includes(current.id);
  const total = current.seconds;
  const elapsed = Math.round((pos / 100) * total);
  const fmt = (s: number) => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`;

  return (
    <div className="relative flex h-full flex-col">
      <Ambient src={current.art} />

      <div className="relative flex items-center gap-2 px-4 pb-1 pt-3">
        <button aria-label="Close player" onClick={back} className="press grid h-9 w-9 place-items-center rounded-full text-[var(--text)]">
          <Icon name="chevronDown" size={22} />
        </button>
        <div className="min-w-0 flex-1 text-center">
          <p className="t-label text-[var(--text-3)]">Now playing</p>
          <p className="t-meta clamp-1 text-[var(--text-2)]">from {current.album}</p>
        </div>
        <button aria-label="More" onClick={() => openSheet("menu")} className="press grid h-9 w-9 place-items-center rounded-full text-[var(--text)]">
          <Icon name="more" size={20} />
        </button>
      </div>

      <div className="relative flex flex-1 flex-col px-6">
        <div className="flex flex-1 items-center justify-center py-3">
          <Art src={current.art} size={286} radius={26} glow seed={2} className="a-fade" />
        </div>

        <div className="flex items-end gap-3">
          <div className="min-w-0 flex-1">
            <h1 className="t-h1 clamp-2">{current.title}</h1>
            <p className="t-body clamp-1 mt-1 text-[var(--text-2)]">{current.artist}</p>
            <p className="t-meta clamp-1 text-[var(--text-3)]">
              {current.album}
              {current.year ? ` · ${current.year}` : ""}
            </p>
          </div>
          <button
            aria-label={fav ? "Remove from favorites" : "Add to favorites"}
            onClick={() => {
              toggleFav(current.id);
              notify(fav ? "Removed from Favorites" : "Added to Favorites");
            }}
            className={`press grid h-11 w-11 place-items-center rounded-full ${fav ? "a-pop" : ""}`}
            style={{ color: fav ? "var(--primary)" : "var(--text-2)" }}
          >
            <Icon name="heart" size={23} filled={fav} />
          </button>
        </div>

        <div className="mt-5">
          <Scrubber value={pos} onChange={setPos} />
          <div className="mt-1 flex justify-between">
            <span className="t-tech text-[var(--text-3)]">{fmt(elapsed)}</span>
            <span className="t-tech text-[var(--text-3)]">−{fmt(total - elapsed)}</span>
          </div>
        </div>

        <div className="mt-4 flex items-center justify-between">
          <IconBtn
            name="shuffle"
            label="Shuffle"
            active={shuffle}
            onClick={() => {
              setShuffle(!shuffle);
              notify(shuffle ? "Shuffle off" : "Shuffle on");
            }}
          />
          <button aria-label="Previous" className="press grid h-12 w-12 place-items-center rounded-full text-[var(--text)]">
            <Icon name="prev" size={27} />
          </button>
          <button
            aria-label={playing ? "Pause" : "Play"}
            onClick={() => setPlaying(!playing)}
            className="press grid h-[68px] w-[68px] place-items-center rounded-full text-[var(--on-primary)]"
            style={{ background: "var(--primary)", boxShadow: "0 16px 40px -12px var(--primary)" }}
          >
            <Icon name={playing ? "pause" : "play"} size={28} />
          </button>
          <button aria-label="Next" className="press grid h-12 w-12 place-items-center rounded-full text-[var(--text)]">
            <Icon name="next" size={27} />
          </button>
          <button
            aria-label="Repeat"
            onClick={() => setRepeat(repeat === "off" ? "all" : repeat === "all" ? "one" : "off")}
            className="press relative grid h-[38px] w-[38px] place-items-center rounded-full"
            style={{ color: repeat === "off" ? "var(--text-2)" : "var(--primary)" }}
          >
            <Icon name="repeat" size={20} />
            {repeat === "one" && (
              <span className="t-tech absolute -bottom-0.5 right-0 rounded-full bg-[var(--primary)] px-1 text-[8px] leading-[12px] text-[var(--on-primary)]">
                1
              </span>
            )}
          </button>
        </div>

        <div className="mt-5 flex items-center justify-between border-t border-[var(--divider)] pb-5 pt-3">
          <IconBtn name="queue" label="Queue" onClick={() => go("queue")} />
          <IconBtn name="lyrics" label="Lyrics" onClick={() => go("lyrics")} />
          <IconBtn name="eq" label="Equalizer" onClick={() => go("equalizer")} />
          <IconBtn name="speed" label="Playback speed" onClick={() => go("audio")} />
          <IconBtn name="share" label="Share" onClick={() => notify("Share sheet opened")} />
        </div>
      </div>
    </div>
  );
}

/* ---------------------------------------------------------- 12 QUEUE */

export function QueueScreen() {
  const { back, go, current, playing, notify } = useLyra();
  const [items, setItems] = useState<Song[]>([songs[8], songs[1], songs[5], songs[4], songs[7], songs[6]]);
  const [dragIndex, setDragIndex] = useState<number | null>(null);
  const [overIndex, setOverIndex] = useState<number | null>(null);

  const move = (from: number, to: number) => {
    if (to < 0 || to >= items.length || from === to) return;
    const next = [...items];
    const [row] = next.splice(from, 1);
    next.splice(to, 0, row);
    setItems(next);
  };

  return (
    <div className="relative flex h-full flex-col">
      <Ambient src={current.art} />
      <div className="relative flex items-center gap-2 px-5 pb-2 pt-3">
        <button aria-label="Back" onClick={back} className="press -ml-2 grid h-9 w-9 place-items-center rounded-full text-[var(--text)]">
          <Icon name="chevronDown" size={22} />
        </button>
        <div className="min-w-0 flex-1">
          <p className="t-label text-[var(--text-3)]">Playing queue</p>
          <h1 className="t-h2">Up next</h1>
        </div>
        <Button
          size="sm"
          variant="ghost"
          onClick={() => {
            setItems([]);
            notify("Queue cleared");
          }}
        >
          Clear
        </Button>
      </div>

      <div className="no-bar relative flex-1 overflow-y-auto px-5 pb-6">
        <div className="mb-4 flex items-center gap-3 rounded-[var(--r-lg)] border border-[var(--divider)] bg-[color-mix(in_srgb,var(--surface)_80%,transparent)] p-3 glass">
          <Art src={current.art} size={52} radius={13} />
          <div className="min-w-0 flex-1">
            <p className="t-label text-[var(--primary)]">Now playing</p>
            <p className="t-title clamp-1">{current.title}</p>
            <p className="t-meta clamp-1 text-[var(--text-2)]">{current.artist}</p>
          </div>
          {playing && <EqBars color="var(--primary)" />}
        </div>

        <div className="mb-2 flex items-center justify-between">
          <SectionHead title={`Next up · ${items.length}`} />
          <span className="t-meta -mt-3 text-[var(--text-3)]">Drag to reorder</span>
        </div>

        {items.length === 0 ? (
          <EmptyState
            icon="queue"
            title="The queue is empty"
            text="Add songs from your library, an album or a playlist to keep the music going."
            action="Open library"
            onAction={() => go("songs")}
          />
        ) : (
          <ul className="space-y-1">
            {items.map((s, i) => (
              <li
                key={`${s.id}-${i}`}
                draggable
                onDragStart={() => setDragIndex(i)}
                onDragOver={(e) => {
                  e.preventDefault();
                  setOverIndex(i);
                }}
                onDrop={() => {
                  if (dragIndex !== null) move(dragIndex, i);
                  setDragIndex(null);
                  setOverIndex(null);
                }}
                onDragEnd={() => {
                  setDragIndex(null);
                  setOverIndex(null);
                }}
                className={`flex items-center gap-1 rounded-[var(--r-md)] px-1 transition-all ${
                  overIndex === i && dragIndex !== null ? "bg-[var(--primary-soft)] ring-1 ring-[var(--primary)]" : ""
                } ${dragIndex === i ? "opacity-40" : ""}`}
              >
                <span className="cursor-grab text-[var(--text-3)] active:cursor-grabbing">
                  <Icon name="grip" size={18} />
                </span>
                <div className="min-w-0 flex-1">
                  <TrackRow
                    song={s}
                    dense
                    onPlay={() => go("player")}
                    trailing={
                      <div className="flex items-center">
                        <button
                          aria-label="Move up"
                          onClick={() => move(i, i - 1)}
                          className="press grid h-8 w-7 place-items-center rounded-full text-[var(--text-3)]"
                        >
                          <Icon name="chevronDown" size={14} className="rotate-180" />
                        </button>
                        <button
                          aria-label="Move down"
                          onClick={() => move(i, i + 1)}
                          className="press grid h-8 w-7 place-items-center rounded-full text-[var(--text-3)]"
                        >
                          <Icon name="chevronDown" size={14} />
                        </button>
                        <button
                          aria-label="Remove from queue"
                          onClick={() => setItems(items.filter((_, x) => x !== i))}
                          className="press grid h-8 w-8 place-items-center rounded-full text-[var(--text-3)]"
                        >
                          <Icon name="close" size={14} />
                        </button>
                      </div>
                    }
                  />
                </div>
              </li>
            ))}
          </ul>
        )}

        <div className="mt-5 flex gap-2">
          <Button variant="secondary" size="sm" icon="shuffle" onClick={() => setItems([...items].reverse())}>
            Shuffle queue
          </Button>
          <Button variant="secondary" size="sm" icon="plus" onClick={() => go("songs")}>
            Add songs
          </Button>
        </div>
      </div>
    </div>
  );
}

/* ---------------------------------------------------------- 22 LYRICS */

export function LyricsScreen() {
  const { back, current, online, notify } = useLyra();
  const [state, setState] = useState<"synced" | "none" | "searching">("synced");
  const [active, setActive] = useState(3);
  const [sheet, setSheet] = useState(false);

  return (
    <div className="relative flex h-full flex-col">
      <Ambient src={current.art} />

      <div className="relative flex items-center gap-2 px-5 pb-2 pt-3">
        <button aria-label="Back" onClick={back} className="press -ml-2 grid h-9 w-9 place-items-center rounded-full text-[var(--text)]">
          <Icon name="chevronDown" size={22} />
        </button>
        <div className="min-w-0 flex-1">
          <p className="t-label text-[var(--text-3)]">Lyrics</p>
          <p className="t-title clamp-1">{current.title}</p>
        </div>
        <button aria-label="Lyrics options" onClick={() => setSheet(true)} className="press grid h-9 w-9 place-items-center rounded-full text-[var(--text)]">
          <Icon name="more" size={20} />
        </button>
      </div>

      {state === "synced" && (
        <>
          <div className="relative flex items-center gap-2 px-5 pb-2">
            <Badge tone="ok">Synced .LRC</Badge>
            <span className="t-meta text-[var(--text-3)]">Stored on device · available offline</span>
          </div>
          <div className="no-bar relative flex-1 overflow-y-auto px-6 pb-8">
            <div className="space-y-5 py-4">
              {lyricData.map((l, i) => (
                <button
                  key={l.t}
                  onClick={() => setActive(i)}
                  className="block w-full text-left transition-all duration-300"
                  style={{
                    opacity: i === active ? 1 : Math.abs(i - active) === 1 ? 0.55 : 0.3,
                    transform: i === active ? "scale(1)" : "scale(0.97)",
                    transformOrigin: "left center",
                  }}
                >
                  <span
                    className="block"
                    style={{
                      fontFamily: '"Plus Jakarta Sans", sans-serif',
                      fontSize: i === active ? 23 : 19,
                      lineHeight: 1.25,
                      fontWeight: i === active ? 800 : 600,
                      letterSpacing: "-0.02em",
                      color: i === active ? "var(--primary)" : "var(--text)",
                    }}
                  >
                    {l.line}
                  </span>
                  {i === active && <span className="t-tech mt-1 block text-[var(--text-3)]">{l.t}</span>}
                </button>
              ))}
              <p className="t-meta pt-4 text-[var(--text-3)]">— instrumental outro —</p>
            </div>
          </div>
        </>
      )}

      {state === "searching" && (
        <div className="relative flex flex-1 flex-col items-center justify-center gap-4 px-8 text-center">
          <div className="h-10 w-10 rounded-full border-2 border-[var(--divider-strong)] border-t-[var(--primary)] a-spin" style={{ animationDuration: "900ms" }} />
          <p className="t-title">Looking for lyrics…</p>
          <p className="t-meta text-[var(--text-2)]">Matching title, artist and duration against online sources.</p>
          <Button variant="secondary" size="sm" onClick={() => { setState("synced"); notify("Lyrics saved on device"); }}>
            Simulate result
          </Button>
        </div>
      )}

      {state === "none" && (
        <div className="relative flex-1 px-5 pt-6">
          <EmptyState
            icon="lyrics"
            title="Lyrics unavailable"
            text="No .LRC file was found next to this song, and nothing is stored locally yet."
            action={online ? "Search for lyrics" : "Add a local .LRC file"}
            onAction={() => (online ? setState("searching") : notify("File picker opened"))}
            secondary="Add .LRC file"
          />
          {!online && (
            <div className="mt-3">
              <Banner
                tone="warn"
                icon="offline"
                title="You are offline"
                text="Online lyrics search will resume automatically when a connection is available."
              />
            </div>
          )}
        </div>
      )}

      <Sheet open={sheet} onClose={() => setSheet(false)} title="Lyrics">
        <div className="px-2 pb-1">
          {[
            ["cloudDown", "Search online again", () => { setSheet(false); setState("searching"); }],
            ["image", "Choose a local .LRC file", () => { setSheet(false); notify("File picker opened"); }],
            ["speed", "Adjust sync offset (−0.3 s)", () => setSheet(false)],
            ["trash", "Remove stored lyrics", () => { setSheet(false); setState("none"); }],
          ].map(([i, l, fn]) => (
            <button
              key={l as string}
              onClick={fn as () => void}
              className="press flex w-full items-center gap-3 rounded-[var(--r-md)] px-3 py-3 text-left"
            >
              <Icon name={i as "cloudDown"} size={18} className="text-[var(--text-2)]" />
              <span className="t-title">{l as string}</span>
            </button>
          ))}
        </div>
        <div className="px-5 pt-2">
          <div className="flex gap-2">
            <Chip active={state === "synced"} onClick={() => { setState("synced"); setSheet(false); }}>
              Synced state
            </Chip>
            <Chip active={state === "none"} onClick={() => { setState("none"); setSheet(false); }}>
              Empty state
            </Chip>
          </div>
        </div>
      </Sheet>
    </div>
  );
}
