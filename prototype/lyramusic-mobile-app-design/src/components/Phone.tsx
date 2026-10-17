import { Icon } from "../lib/icons";
import type { IconName } from "../lib/icons";
import {
  Art,
  EqBars,
  LyraProvider,
  Sheet,
  Toast,
  useLyra,
} from "../lib/ui";
import { songs } from "../lib/data";
import type { ScreenId } from "../lib/data";
import {
  AlbumsScreen,
  ArtistsScreen,
  FoldersScreen,
  GenresScreen,
  HomeScreen,
  PermissionScreen,
  SearchScreen,
  SongsScreen,
  SplashScreen,
} from "../screens/core";
import { LyricsScreen, PlayerScreen, QueueScreen } from "../screens/playback";
import {
  CreatePlaylistScreen,
  FavoritesScreen,
  HistoryScreen,
  PlaylistDetailScreen,
  PlaylistsScreen,
} from "../screens/collections";
import {
  ArtworkScreen,
  EnrichmentScreen,
  MetadataScreen,
  SongDetailsScreen,
} from "../screens/metadata";
import {
  AddToPlaylistContent,
  AudioScreen,
  EmptyStatesScreen,
  EqualizerScreen,
  ErrorStatesScreen,
  OfflineScreen,
  SettingsScreen,
  SongMenuContent,
  SongMenuScreen,
  ThemesScreen,
} from "../screens/system";

/* screens rendered edge-to-edge without mini player / tab bar */
const FULLSCREEN: ScreenId[] = [
  "splash",
  "permission",
  "player",
  "queue",
  "lyrics",
  "createPlaylist",
  "metadata",
];

function StatusBar() {
  const { online } = useLyra();
  return (
    <div className="relative z-30 flex h-[42px] shrink-0 items-end justify-between px-7 pb-1">
      <span className="t-meta font-semibold tracking-tight text-[var(--text)]">9:41</span>
      <div className="flex items-center gap-1.5 text-[var(--text)]">
        {!online && <Icon name="offline" size={12} />}
        <svg width="16" height="11" viewBox="0 0 16 11" fill="currentColor" aria-hidden>
          <rect x="0" y="7" width="2.6" height="4" rx="0.8" opacity=".45" />
          <rect x="4" y="5" width="2.6" height="6" rx="0.8" opacity=".7" />
          <rect x="8" y="2.6" width="2.6" height="8.4" rx="0.8" />
          <rect x="12" y="0" width="2.6" height="11" rx="0.8" />
        </svg>
        <svg width="15" height="11" viewBox="0 0 15 11" fill="none" stroke="currentColor" strokeWidth="1.3" aria-hidden>
          <path d="M1 3.7a9 9 0 0 1 13 0M3.4 6.3a5.6 5.6 0 0 1 8.2 0" strokeLinecap="round" />
          <circle cx="7.5" cy="9.2" r="1.1" fill="currentColor" stroke="none" />
        </svg>
        <svg width="24" height="11" viewBox="0 0 24 11" fill="none" aria-hidden>
          <rect x="0.6" y="0.6" width="19" height="9.8" rx="2.6" stroke="currentColor" strokeOpacity=".45" />
          <rect x="2.2" y="2.2" width="13.5" height="6.6" rx="1.5" fill="currentColor" />
          <path d="M21.4 3.8v3.4c.9-.3 1.4-.9 1.4-1.7s-.5-1.4-1.4-1.7Z" fill="currentColor" fillOpacity=".45" />
        </svg>
      </div>
    </div>
  );
}

function MiniPlayer() {
  const { current, playing, setPlaying, go, favs } = useLyra();
  const fav = favs.includes(current.id);
  return (
    <div className="a-fade px-3 pb-1.5">
      <div className="relative overflow-hidden rounded-[18px] border border-[var(--divider)] bg-[color-mix(in_srgb,var(--elevated)_92%,transparent)] glass shadow-[0_10px_30px_-12px_rgba(0,0,0,.7)]">
        <button onClick={() => go("player")} className="press flex w-full items-center gap-3 p-2 pr-1 text-left">
          <div className="relative">
            <Art src={current.art} size={42} radius={11} />
            {playing && (
              <span className="absolute inset-0 grid place-items-center rounded-[11px] bg-black/40">
                <EqBars />
              </span>
            )}
          </div>
          <span className="min-w-0 flex-1">
            <span className="t-title clamp-1 block">{current.title}</span>
            <span className="t-meta clamp-1 block text-[var(--text-2)]">{current.artist}</span>
          </span>
          <span
            onClick={(e) => e.stopPropagation()}
            className="grid h-9 w-9 place-items-center rounded-full"
            style={{ color: fav ? "var(--primary)" : "var(--text-3)" }}
          >
            <Icon name="heart" size={17} filled={fav} />
          </span>
          <span
            onClick={(e) => {
              e.stopPropagation();
              setPlaying(!playing);
            }}
            className="press mr-1 grid h-9 w-9 place-items-center rounded-full text-[var(--text)]"
          >
            <Icon name={playing ? "pause" : "play"} size={19} />
          </span>
        </button>
        <div className="h-[2px] w-full bg-[var(--divider)]">
          <div className="h-full bg-[var(--primary)]" style={{ width: "44%" }} />
        </div>
      </div>
    </div>
  );
}

const tabs: { id: ScreenId; label: string; icon: IconName; match: ScreenId[] }[] = [
  { id: "home", label: "Home", icon: "home", match: ["home"] },
  { id: "songs", label: "Library", icon: "library", match: ["songs", "albums", "artists", "genres", "folders", "songDetails", "menu"] },
  { id: "search", label: "Search", icon: "search", match: ["search", "results"] },
  { id: "playlists", label: "Playlists", icon: "playlist", match: ["playlists", "playlistDetail", "favorites", "history", "createPlaylist"] },
  { id: "settings", label: "Settings", icon: "settings", match: ["settings", "themes", "audio", "equalizer", "offline", "empty", "errors"] },
];

function TabBar() {
  const { screen, go } = useLyra();
  return (
    <nav className="flex shrink-0 items-stretch gap-1 border-t border-[var(--divider)] bg-[color-mix(in_srgb,var(--bg)_94%,transparent)] px-2 pb-1 pt-1.5 glass">
      {tabs.map((t) => {
        const active = t.match.includes(screen);
        return (
          <button
            key={t.id}
            onClick={() => go(t.id)}
            aria-current={active ? "page" : undefined}
            className="press relative flex flex-1 flex-col items-center gap-1 rounded-[14px] py-1.5"
            style={{ color: active ? "var(--primary)" : "var(--text-3)" }}
          >
            {active && (
              <span className="absolute -top-[7px] h-[3px] w-7 rounded-full" style={{ background: "var(--primary)" }} />
            )}
            <Icon name={t.icon} size={21} strokeWidth={active ? 2 : 1.7} />
            <span style={{ fontSize: 9.5, fontWeight: active ? 700 : 500, letterSpacing: "0.01em" }}>{t.label}</span>
          </button>
        );
      })}
    </nav>
  );
}

function Router() {
  const { screen } = useLyra();
  switch (screen) {
    case "splash":
      return <SplashScreen />;
    case "permission":
      return <PermissionScreen />;
    case "home":
      return <HomeScreen />;
    case "songs":
      return <SongsScreen />;
    case "albums":
      return <AlbumsScreen />;
    case "artists":
      return <ArtistsScreen />;
    case "genres":
      return <GenresScreen />;
    case "folders":
      return <FoldersScreen />;
    case "search":
      return <SearchScreen />;
    case "results":
      return <SearchScreen withResults />;
    case "player":
      return <PlayerScreen />;
    case "queue":
      return <QueueScreen />;
    case "lyrics":
      return <LyricsScreen />;
    case "playlists":
      return <PlaylistsScreen />;
    case "createPlaylist":
      return <CreatePlaylistScreen />;
    case "playlistDetail":
      return <PlaylistDetailScreen />;
    case "favorites":
      return <FavoritesScreen />;
    case "history":
      return <HistoryScreen />;
    case "songDetails":
      return <SongDetailsScreen />;
    case "metadata":
      return <MetadataScreen />;
    case "enrichment":
      return <EnrichmentScreen />;
    case "artwork":
      return <ArtworkScreen />;
    case "equalizer":
      return <EqualizerScreen />;
    case "audio":
      return <AudioScreen />;
    case "settings":
      return <SettingsScreen />;
    case "themes":
      return <ThemesScreen />;
    case "offline":
      return <OfflineScreen />;
    case "empty":
      return <EmptyStatesScreen />;
    case "errors":
      return <ErrorStatesScreen />;
    case "menu":
      return <SongMenuScreen />;
    default:
      return <HomeScreen />;
  }
}

function PhoneBody() {
  const { screen, sheet, closeSheet, toast } = useLyra();
  const full = FULLSCREEN.includes(screen);
  const scrolls = !["splash", "permission", "player", "queue", "lyrics", "createPlaylist", "metadata", "menu"].includes(screen);

  return (
    <div className="relative flex h-full flex-col overflow-hidden" style={{ background: "var(--bg)" }}>
      <StatusBar />

      <div className={`relative flex-1 ${scrolls ? "no-bar overflow-y-auto" : "overflow-hidden"}`}>
        <div key={screen} className={scrolls ? "a-fade min-h-full" : "a-fade h-full"}>
          <Router />
        </div>
      </div>

      {!full && (
        <div className="relative z-20 shrink-0">
          <MiniPlayer />
          <TabBar />
        </div>
      )}

      <div className="relative z-20 flex h-[18px] shrink-0 items-center justify-center" style={{ background: full ? "transparent" : "color-mix(in srgb,var(--bg) 94%,transparent)" }}>
        <span className="h-[4px] w-[108px] rounded-full" style={{ background: "var(--text)", opacity: 0.28 }} />
      </div>

      <Sheet open={sheet === "menu"} onClose={closeSheet}>
        <SongMenuContent onClose={closeSheet} />
      </Sheet>
      <Sheet open={sheet === "addToPlaylist"} onClose={closeSheet} title="Add to playlist">
        <AddToPlaylistContent onClose={closeSheet} />
      </Sheet>

      <Toast message={toast} />
    </div>
  );
}

export function Phone({
  screen,
  theme,
  setTheme,
  frozen = false,
  scale = 1,
  label,
  onNavigate,
}: {
  screen: ScreenId;
  theme: string;
  setTheme: (t: string) => void;
  frozen?: boolean;
  scale?: number;
  label?: string;
  onNavigate?: (s: ScreenId) => void;
}) {
  const W = 390;
  const H = 844;
  return (
    <div className="flex flex-col items-center" style={{ width: W * scale }}>
      <div className="relative" style={{ width: W * scale, height: H * scale }}>
        <div
          className="absolute left-0 top-0"
          style={{ width: W, height: H, transform: `scale(${scale})`, transformOrigin: "top left" }}
        >
          <div className="frame-shadow relative h-full w-full rounded-[54px] bg-[#0a0a0d] p-[11px]">
            <div
            className="lyra relative h-full w-full overflow-hidden rounded-[44px]"
            data-theme={theme === "system" ? "dark" : theme}
          >
              <div className="pointer-events-none absolute left-1/2 top-[11px] z-40 h-[26px] w-[104px] -translate-x-1/2 rounded-full bg-black" />
              <LyraProvider
                initial={screen}
                theme={theme}
                setTheme={setTheme}
                frozen={frozen}
                startSong={songs[0]}
                onNavigate={onNavigate}
              >
                <PhoneBody />
              </LyraProvider>
            </div>
          </div>
        </div>
      </div>
      {label && <p className="t-meta w-full pt-3 text-center text-white/45">{label}</p>}
    </div>
  );
}
