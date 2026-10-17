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
  EmptyState,
  EqBars,
  Group,
  Mosaic,
  Progress,
  SectionHead,
  SettingRow,
  TrackRow,
  useLyra,
} from "../lib/ui";
import { albums, artists, folders, genres, playlists, songs } from "../lib/data";

export function Wordmark({ size = 28 }: { size?: number }) {
  return (
    <div className="flex items-center gap-2.5">
      <div
        className="relative grid place-items-center overflow-hidden rounded-[9px]"
        style={{
          width: size,
          height: size,
          background: "linear-gradient(145deg,var(--primary),#2b2350 85%)",
          boxShadow: "0 6px 18px -6px color-mix(in srgb,var(--primary) 70%,transparent)",
        }}
      >
        <svg width={size * 0.62} height={size * 0.62} viewBox="0 0 24 24" fill="none">
          <path d="M6 19V5.6l3.4 1.2V19" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" />
          <path d="M14.6 19V8.4L18 9.6V19" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" opacity=".75" />
          <path d="M6 5.6 18 9.6" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" opacity=".5" />
        </svg>
      </div>
      <span
        className="t-h2 tracking-[-0.03em]"
        style={{ fontFamily: '"Plus Jakarta Sans", sans-serif' }}
      >
        Lyra<span className="text-[var(--text-3)]">Music</span>
      </span>
    </div>
  );
}

/* ---------------------------------------------------------- 01 SPLASH */

export function SplashScreen() {
  const { go } = useLyra();
  return (
    <div className="relative flex h-full flex-col items-center justify-center px-8 text-center">
      <div
        className="pointer-events-none absolute left-1/2 top-[30%] h-72 w-72 -translate-x-1/2 rounded-full blur-[80px]"
        style={{ background: "color-mix(in srgb,var(--primary) 45%,transparent)" }}
      />
      <div className="a-pop relative">
        <div
          className="grid h-[86px] w-[86px] place-items-center rounded-[26px]"
          style={{
            background: "linear-gradient(150deg,var(--primary),#241f44)",
            boxShadow: "0 24px 60px -18px color-mix(in srgb,var(--primary) 80%,transparent)",
          }}
        >
          <svg width="44" height="44" viewBox="0 0 24 24" fill="none">
            <path d="M6 19V5.6l3.4 1.2V19" stroke="#fff" strokeWidth="2.3" strokeLinecap="round" />
            <path d="M14.6 19V8.4L18 9.6V19" stroke="#fff" strokeWidth="2.3" strokeLinecap="round" opacity=".75" />
            <path d="M6 5.6 18 9.6" stroke="#fff" strokeWidth="2.3" strokeLinecap="round" opacity=".5" />
          </svg>
        </div>
      </div>
      <h1 className="t-display a-fade mt-7">LyraMusic</h1>
      <p className="t-body a-fade mt-2 max-w-[15rem] text-[var(--text-2)]">
        Your music. On your device. Beautifully organised.
      </p>

      <div className="absolute inset-x-8 bottom-12">
        <div className="mb-5 flex items-center justify-center gap-2 text-[var(--text-3)]">
          <span className="h-1 w-1 animate-pulse rounded-full bg-current" />
          <span className="t-meta">Preparing local library…</span>
        </div>
        <div className="mx-auto h-[3px] w-40 overflow-hidden rounded-full bg-[var(--divider-strong)]">
          <div className="h-full w-2/3 rounded-full bg-[var(--primary)]" />
        </div>
        <button onClick={() => go("permission")} className="press t-label mt-8 w-full text-[var(--text-3)]">
          Tap to continue
        </button>
      </div>
    </div>
  );
}

/* ---------------------------------------------------------- 02 PERMISSION */

export function PermissionScreen() {
  const { go, notify } = useLyra();
  const [state, setState] = useState<"ask" | "denied" | "restricted" | "granted">("ask");

  return (
    <div className="flex h-full flex-col px-5 pb-6 pt-8">
      <div
        className="grid h-14 w-14 place-items-center rounded-[18px]"
        style={{ background: "var(--primary-soft)", color: "var(--primary)" }}
      >
        <Icon name="folder" size={26} />
      </div>
      <h1 className="t-h1 mt-5">Let LyraMusic find your songs</h1>
      <p className="t-body mt-2 text-[var(--text-2)]">
        We need to look at the audio files saved on this phone so your albums, artists and playlists
        can appear here. Nothing is uploaded anywhere.
      </p>

      <div className="mt-6 space-y-2.5">
        {[
          ["note", "Reads only audio files", "Photos, messages and documents are never opened."],
          ["offline", "Works without internet", "Scanning and playback happen entirely on device."],
          ["shield", "You stay in control", "Choose folders to include or exclude at any time."],
        ].map(([i, t, s]) => (
          <div key={t} className="flex gap-3 rounded-[var(--r-md)] bg-[var(--surface)] p-3">
            <span className="mt-px text-[var(--primary)]">
              <Icon name={i as "note"} size={17} />
            </span>
            <div>
              <p className="t-title text-[var(--text)]">{t}</p>
              <p className="t-meta text-[var(--text-2)]">{s}</p>
            </div>
          </div>
        ))}
      </div>

      {state === "denied" && (
        <div className="mt-4">
          <Banner
            tone="err"
            icon="alert"
            title="Music access is turned off"
            text="LyraMusic can still play files you open manually, but your library stays empty."
            action="Open phone settings"
          />
        </div>
      )}
      {state === "restricted" && (
        <div className="mt-4">
          <Banner
            tone="warn"
            icon="shield"
            title="Partial access granted"
            text="Only selected folders are visible. Some albums may be missing."
            action="Choose more folders"
          />
        </div>
      )}
      {state === "granted" && (
        <div className="mt-4">
          <Banner tone="ok" icon="check" title="Access granted" text="612 songs found in 4 folders." />
        </div>
      )}

      <div className="mt-auto space-y-2.5 pt-6">
        <Button
          full
          onClick={() => {
            setState("granted");
            notify("Library scan started");
            window.setTimeout(() => go("home"), 450);
          }}
        >
          Allow music access
        </Button>
        <div className="flex gap-2">
          <Button variant="secondary" size="sm" full onClick={() => setState("denied")}>
            Not now
          </Button>
          <Button variant="secondary" size="sm" full onClick={() => setState("restricted")}>
            Select folders
          </Button>
        </div>
        <p className="t-meta pt-1 text-center text-[var(--text-3)]">
          You can change this later in Settings → Permissions.
        </p>
      </div>
    </div>
  );
}

/* ---------------------------------------------------------- 03 HOME */

export function HomeScreen() {
  const { go, play, current, playing, setPlaying, openSheet, online } = useLyra();
  const resume = current;

  return (
    <div className="px-5 pb-4">
      <div className="flex items-center justify-between pb-4 pt-3">
        <Wordmark />
        <div className="flex items-center gap-1">
          {!online && (
            <span className="mr-1">
              <Badge tone="warn">Offline</Badge>
            </span>
          )}
          <button
            aria-label="Search"
            onClick={() => go("search")}
            className="press grid h-9 w-9 place-items-center rounded-full text-[var(--text-2)]"
          >
            <Icon name="search" size={20} />
          </button>
          <button
            aria-label="History"
            onClick={() => go("history")}
            className="press grid h-9 w-9 place-items-center rounded-full text-[var(--text-2)]"
          >
            <Icon name="clock" size={20} />
          </button>
        </div>
      </div>

      <p className="t-label text-[var(--text-3)]">Good evening</p>
      <h2 className="t-h1 mt-1">612 songs, all on your device</h2>

      {/* Resume playback */}
      <div className="relative mt-5 overflow-hidden rounded-[var(--r-xl)] border border-[var(--divider)]">
        <div className="absolute inset-0">
          <Art src={resume.art} size="fill" radius={0} seed={1} />
          <div className="absolute inset-0 backdrop-blur-2xl" style={{ background: "color-mix(in srgb,var(--bg) 72%,transparent)" }} />
        </div>
        <div className="relative p-4">
          <div className="flex items-center justify-between">
            <span className="t-label text-[var(--text-2)]">Resume playback</span>
            <span className="t-meta text-[var(--text-3)]">1:54 left</span>
          </div>
          <button onClick={() => go("player")} className="press mt-3 flex w-full items-center gap-3.5 text-left">
            <Art src={resume.art} size={74} radius={16} glow />
            <span className="min-w-0 flex-1">
              <span className="t-h3 clamp-2 block text-[var(--text)]">{resume.title}</span>
              <span className="t-meta clamp-1 mt-1 block text-[var(--text-2)]">{resume.artist}</span>
              <span className="t-meta clamp-1 block text-[var(--text-3)]">{resume.album}</span>
            </span>
            <span
              onClick={(e) => {
                e.stopPropagation();
                setPlaying(!playing);
              }}
              className="press grid h-12 w-12 shrink-0 place-items-center rounded-full text-[var(--on-primary)]"
              style={{ background: "var(--primary)", boxShadow: "0 10px 28px -10px var(--primary)" }}
            >
              <Icon name={playing ? "pause" : "play"} size={20} />
            </span>
          </button>
          <div className="mt-3.5 flex items-center gap-2">
            <span className="t-tech text-[var(--text-3)]">2:24</span>
            <Progress value={56} />
            <span className="t-tech text-[var(--text-3)]">{resume.duration}</span>
          </div>
        </div>
      </div>

      {/* Quick chips */}
      <div className="no-bar -mx-5 mt-4 flex gap-2 overflow-x-auto px-5">
        <Chip icon="shuffle" onClick={() => go("player")}>Shuffle all</Chip>
        <Chip icon="heart" onClick={() => go("favorites")}>Favorites</Chip>
        <Chip icon="clock" onClick={() => go("history")}>History</Chip>
        <Chip icon="scan" onClick={() => go("settings")}>Rescan</Chip>
      </div>

      {/* Recently played */}
      <div className="mt-7">
        <SectionHead title="Recently played" action="History" onAction={() => go("history")} />
        <div className="no-bar -mx-5 flex gap-3.5 overflow-x-auto px-5 pb-1">
          {[songs[0], songs[8], songs[5], songs[4], songs[6]].map((s, i) => (
            <button
              key={s.id}
              onClick={() => {
                play(s);
                go("player");
              }}
              className="press w-[116px] shrink-0 text-left"
            >
              <Art src={s.art} size={116} radius={16} seed={i} />
              <p className="t-title clamp-1 mt-2 text-[var(--text)]">{s.title}</p>
              <p className="t-meta clamp-1 text-[var(--text-2)]">{s.artist}</p>
            </button>
          ))}
        </div>
      </div>

      {/* Recently added */}
      <div className="mt-7">
        <SectionHead title="Recently added" action="See all" onAction={() => go("songs")} />
        <div className="space-y-1">
          {[songs[8], songs[3], songs[7]].map((s, i) => (
            <TrackRow
              key={s.id}
              song={s}
              onPlay={() => {
                play(s);
                go("player");
              }}
              onMenu={() => openSheet("menu")}
              trailing={
                i === 0 ? (
                  <Badge tone="accent">New</Badge>
                ) : s.incomplete ? (
                  <button onClick={() => go("songDetails")} className="press">
                    <Badge tone="warn">Fix info</Badge>
                  </button>
                ) : undefined
              }
            />
          ))}
        </div>
      </div>

      {/* Favorites */}
      <div className="mt-7">
        <SectionHead title="Recently favorited" action="All favorites" onAction={() => go("favorites")} />
        <div className="space-y-1">
          {[songs[0], songs[4], songs[8]].map((s) => (
            <TrackRow
              key={s.id}
              song={s}
              onPlay={() => {
                play(s);
                go("player");
              }}
              trailing={
                <span className="px-2 text-[var(--primary)]">
                  <Icon name="heart" size={16} filled />
                </span>
              }
            />
          ))}
        </div>
      </div>

      {/* Playlists */}
      <div className="mt-7">
        <SectionHead title="Your playlists" action="Manage" onAction={() => go("playlists")} />
        <div className="no-bar -mx-5 flex gap-3.5 overflow-x-auto px-5 pb-1">
          {playlists.map((p) => (
            <button key={p.id} onClick={() => go("playlistDetail")} className="press w-[116px] shrink-0 text-left">
              <Mosaic art={p.art} size={116} radius={16} />
              <p className="t-title clamp-1 mt-2 text-[var(--text)]">{p.name}</p>
              <p className="t-meta text-[var(--text-2)]">{p.count} songs</p>
            </button>
          ))}
        </div>
      </div>

      <p className="t-meta mt-8 text-center text-[var(--text-3)]">
        Local library · last scanned 14 min ago
      </p>
    </div>
  );
}

/* ---------------------------------------------------------- 04–08 LIBRARY */

const libTabs = [
  { id: "songs", label: "Songs" },
  { id: "albums", label: "Albums" },
  { id: "artists", label: "Artists" },
  { id: "genres", label: "Genres" },
  { id: "folders", label: "Folders" },
  { id: "composers", label: "Composers" },
  { id: "years", label: "Years" },
] as const;

function LibraryShell({ active, children }: { active: string; children: React.ReactNode }) {
  const { go } = useLyra();
  return (
    <div className="px-5 pb-4">
      <AppBar
        title="Library"
        subtitle="612 songs · 4 folders"
        large
        right={
          <div className="flex gap-1">
            <button aria-label="Sort" onClick={() => go("songs")} className="press grid h-9 w-9 place-items-center rounded-full text-[var(--text-2)]">
              <Icon name="sort" size={19} />
            </button>
            <button aria-label="Search" onClick={() => go("search")} className="press grid h-9 w-9 place-items-center rounded-full text-[var(--text-2)]">
              <Icon name="search" size={19} />
            </button>
          </div>
        }
      />
      <div className="no-bar sticky top-[52px] z-10 -mx-5 flex gap-2 overflow-x-auto bg-[color-mix(in_srgb,var(--bg)_90%,transparent)] px-5 py-2 glass">
        {libTabs.map((t) => (
          <Chip
            key={t.id}
            active={t.id === active}
            onClick={() => {
              const map: Record<string, string> = {
                songs: "songs",
                albums: "albums",
                artists: "artists",
                genres: "genres",
                folders: "folders",
                composers: "artists",
                years: "albums",
              };
              go(map[t.id] as never);
            }}
          >
            {t.label}
          </Chip>
        ))}
      </div>
      <div className="pt-3">{children}</div>
    </div>
  );
}

export function SongsScreen() {
  const { play, go, openSheet, current, playing } = useLyra();
  return (
    <LibraryShell active="songs">
      <div className="mb-3 flex items-center gap-2">
        <Button size="sm" icon="play" onClick={() => go("player")}>
          Play all
        </Button>
        <Button size="sm" variant="secondary" icon="shuffle" onClick={() => go("player")}>
          Shuffle
        </Button>
        <span className="t-meta ml-auto text-[var(--text-3)]">A–Z</span>
      </div>
      <div className="space-y-0.5">
        {songs.map((s, i) => (
          <TrackRow
            key={s.id}
            song={s}
            index={i + 1}
            playingNow={playing && s.id === current.id}
            onPlay={() => {
              play(s);
              go("player");
            }}
            onMenu={() => openSheet("menu")}
          />
        ))}
      </div>
      <div className="mt-4">
        <Banner
          icon="info"
          title="4 files have incomplete information"
          text="LyraMusic never invents missing tags. Review them whenever you like."
          action="Review files"
          onAction={() => go("enrichment")}
        />
      </div>
    </LibraryShell>
  );
}

export function AlbumsScreen() {
  const { go } = useLyra();
  return (
    <LibraryShell active="albums">
      <div className="grid grid-cols-2 gap-x-4 gap-y-5">
        {albums.map((a, i) => (
          <button key={a.id} onClick={() => go("songs")} className="press text-left">
            <Art src={a.art} size="100%" radius={16} seed={i} />
            <p className="t-title clamp-1 mt-2 text-[var(--text)]">{a.title}</p>
            <p className="t-meta clamp-1 text-[var(--text-2)]">{a.artist}</p>
            <p className="t-meta text-[var(--text-3)]">
              {a.year} · {a.count} songs
            </p>
          </button>
        ))}
      </div>
    </LibraryShell>
  );
}

export function ArtistsScreen() {
  const { go } = useLyra();
  return (
    <LibraryShell active="artists">
      <div className="space-y-1">
        {artists.map((a, i) => (
          <button key={a.name} onClick={() => go("albums")} className="press flex w-full items-center gap-3 rounded-[var(--r-md)] py-1.5 text-left">
            <Art src={a.art} size={48} radius={999} seed={i} />
            <span className="min-w-0 flex-1">
              <span className="t-title clamp-1 block text-[var(--text)]">{a.name}</span>
              <span className="t-meta block text-[var(--text-2)]">
                {a.albums} albums · {a.tracks} songs
              </span>
            </span>
            <Icon name="chevronRight" size={16} className="text-[var(--text-3)]" />
          </button>
        ))}
      </div>
    </LibraryShell>
  );
}

export function GenresScreen() {
  const { go } = useLyra();
  return (
    <LibraryShell active="genres">
      <div className="grid grid-cols-2 gap-3">
        {genres.map((g, i) => (
          <button
            key={g.name}
            onClick={() => go("songs")}
            className="press relative h-[96px] overflow-hidden rounded-[var(--r-lg)] text-left"
          >
            <Art src={g.art} size="fill" radius={0} seed={i} className="absolute inset-0" />
            <span className="absolute inset-0" style={{ background: "linear-gradient(180deg,rgba(8,8,12,.1),rgba(8,8,12,.86))" }} />
            <span className="absolute inset-x-3 bottom-2.5">
              <span className="t-h3 clamp-1 block text-white">{g.name}</span>
              <span className="t-meta block text-white/65">{g.tracks} songs</span>
            </span>
          </button>
        ))}
      </div>
    </LibraryShell>
  );
}

export function FoldersScreen() {
  const { go } = useLyra();
  return (
    <LibraryShell active="folders">
      <p className="t-meta mb-3 text-[var(--text-2)]">
        Only folders containing audio are listed. LyraMusic is not a file browser.
      </p>
      <Group>
        {folders.map((f) => (
          <SettingRow
            key={f.path}
            icon="folder"
            title={f.path}
            value={f.sub}
            onClick={() => go("songs")}
            tone={f.excluded ? "var(--text-3)" : "var(--primary)"}
            right={
              f.excluded ? (
                <Badge>Excluded</Badge>
              ) : (
                <span className="t-tech text-[var(--text-3)]">{f.count}</span>
              )
            }
          />
        ))}
      </Group>
      <div className="mt-3">
        <Button variant="secondary" full icon="plus" onClick={() => go("settings")}>
          Add a folder to the library
        </Button>
      </div>
    </LibraryShell>
  );
}

/* ---------------------------------------------------------- 09–10 SEARCH */

export function SearchScreen({ withResults = false }: { withResults?: boolean }) {
  const { go, play, openSheet } = useLyra();
  const [q, setQ] = useState(withResults ? "harbor" : "");
  const [none, setNone] = useState(false);
  const query = none ? "zzqx" : q;
  const results = query.trim().length > 0;

  const matchedSongs = none ? [] : [songs[1], songs[8], songs[0]];

  return (
    <div className="px-5 pb-4">
      <AppBar title="Search" subtitle="Your device only" large />
      <div className="sticky top-[52px] z-10 -mx-5 bg-[color-mix(in_srgb,var(--bg)_90%,transparent)] px-5 pb-2 glass">
        <div className="flex h-11 items-center gap-2.5 rounded-full border border-[var(--divider)] bg-[var(--surface)] px-4">
          <Icon name="search" size={18} className="shrink-0 text-[var(--text-3)]" />
          <input
            value={query}
            onChange={(e) => {
              setNone(false);
              setQ(e.target.value);
              if (e.target.value && !withResults) go("results");
            }}
            placeholder="Songs, artists, albums, playlists"
            className="t-body min-w-0 flex-1 bg-transparent text-[var(--text)] outline-none placeholder:text-[var(--text-3)]"
          />
          {query && (
            <button
              aria-label="Clear"
              onClick={() => {
                setQ("");
                setNone(false);
              }}
              className="press grid h-6 w-6 place-items-center rounded-full bg-[var(--surface-2)] text-[var(--text-2)]"
            >
              <Icon name="close" size={12} />
            </button>
          )}
        </div>
      </div>

      {!results && (
        <div className="pt-3">
          <SectionHead title="Recent searches" action="Clear" />
          <div className="mb-6 flex flex-wrap gap-2">
            {["northern arc", "piano", "2024", "flac", "unknown"].map((t) => (
              <Chip key={t} icon="clock" onClick={() => { setQ(t); go("results"); }}>
                {t}
              </Chip>
            ))}
          </div>
          <SectionHead title="Browse by" />
          <div className="grid grid-cols-2 gap-3">
            {[
              ["disc", "Albums", "albums"],
              ["person", "Artists", "artists"],
              ["tag", "Genres", "genres"],
              ["folder", "Folders", "folders"],
            ].map(([i, l, s]) => (
              <Card key={l} onClick={() => go(s as never)} className="flex items-center gap-2.5">
                <span className="text-[var(--primary)]">
                  <Icon name={i as "disc"} size={18} />
                </span>
                <span className="t-title">{l}</span>
              </Card>
            ))}
          </div>
          <button onClick={() => { setQ("zzqx"); setNone(true); }} className="press t-meta mt-6 w-full text-center text-[var(--text-3)]">
            Preview the “no results” state
          </button>
        </div>
      )}

      {results && none && (
        <div className="pt-6">
          <EmptyState
            icon="search"
            title="No matches for “zzqx”"
            text="Check the spelling, or rescan your folders if the song was added recently."
            action="Rescan library"
            onAction={() => go("settings")}
            secondary="Clear search"
          />
        </div>
      )}

      {results && !none && (
        <div className="a-fade space-y-6 pt-3">
          <section>
            <SectionHead title="Songs" action="12 results" />
            <div className="space-y-0.5">
              {matchedSongs.map((s) => (
                <TrackRow
                  key={s.id}
                  song={s}
                  onPlay={() => {
                    play(s);
                    go("player");
                  }}
                  onMenu={() => openSheet("menu")}
                />
              ))}
            </div>
          </section>

          <section>
            <SectionHead title="Artists" />
            <div className="space-y-1">
              {[artists[0]].map((a, i) => (
                <button key={a.name} onClick={() => go("artists")} className="press flex w-full items-center gap-3 text-left">
                  <Art src={a.art} size={44} radius={999} seed={i} />
                  <span className="min-w-0 flex-1">
                    <span className="t-title block text-[var(--text)]">{a.name}</span>
                    <span className="t-meta block text-[var(--text-2)]">Artist · {a.tracks} songs</span>
                  </span>
                </button>
              ))}
            </div>
          </section>

          <section>
            <SectionHead title="Albums" />
            <div className="no-bar -mx-5 flex gap-3.5 overflow-x-auto px-5">
              {[albums[1], albums[0]].map((a, i) => (
                <button key={a.id} onClick={() => go("albums")} className="press w-[104px] shrink-0 text-left">
                  <Art src={a.art} size={104} radius={14} seed={i} />
                  <p className="t-title clamp-1 mt-1.5">{a.title}</p>
                  <p className="t-meta clamp-1 text-[var(--text-2)]">{a.artist}</p>
                </button>
              ))}
            </div>
          </section>

          <section>
            <SectionHead title="Playlists" />
            <button onClick={() => go("playlistDetail")} className="press flex w-full items-center gap-3 text-left">
              <Mosaic art={playlists[1].art} size={46} radius={12} />
              <span className="min-w-0 flex-1">
                <span className="t-title block">{playlists[1].name}</span>
                <span className="t-meta block text-[var(--text-2)]">Playlist · {playlists[1].count} songs</span>
              </span>
              <EqBars color="var(--primary)" />
            </button>
          </section>
        </div>
      )}
    </div>
  );
}
