import { useMemo, useState } from "react";
import { Phone } from "./components/Phone";
import { screenIndex, themeList } from "./lib/data";
import type { ScreenId } from "./lib/data";

const flows: { label: string; steps: { s: ScreenId; t: string }[] }[] = [
  {
    label: "Play a song",
    steps: [
      { s: "home", t: "Home" },
      { s: "player", t: "Full player" },
      { s: "queue", t: "Queue" },
    ],
  },
  {
    label: "Fix a file with missing tags",
    steps: [
      { s: "songDetails", t: "Song details" },
      { s: "enrichment", t: "Enrichment" },
      { s: "metadata", t: "Editor" },
      { s: "artwork", t: "Artwork" },
    ],
  },
  {
    label: "Build a playlist",
    steps: [
      { s: "playlists", t: "Playlists" },
      { s: "createPlaylist", t: "Create" },
      { s: "playlistDetail", t: "Reorder" },
    ],
  },
  {
    label: "Tune the sound",
    steps: [
      { s: "settings", t: "Settings" },
      { s: "audio", t: "Audio" },
      { s: "equalizer", t: "Equalizer" },
      { s: "themes", t: "Themes" },
    ],
  },
];

const tokens: [string, string, string][] = [
  ["Primary", "#7B6CFF", "var(--primary)"],
  ["Secondary", "#F0A561", "var(--secondary)"],
  ["Accent", "#4FD1B5", "var(--accent)"],
  ["Background", "#0B0B11", "var(--bg)"],
  ["Surface", "#14141D", "var(--surface)"],
  ["Elevated", "#222231", "var(--elevated)"],
  ["Text", "#F4F3F8", "var(--text)"],
  ["Text 2", "#A3A2B4", "var(--text-2)"],
  ["Text 3", "#6E6D80", "var(--text-3)"],
  ["Success", "#41C98A", "var(--success)"],
  ["Warning", "#E3A648", "var(--warning)"],
  ["Error", "#F0646A", "var(--error)"],
];

export default function App() {
  const [theme, setTheme] = useState("dark");
  const [start, setStart] = useState<ScreenId>("home");
  const [live, setLive] = useState<ScreenId>("home");
  const [seq, setSeq] = useState(0);
  const [mode, setMode] = useState<"prototype" | "gallery">("prototype");

  const groups = useMemo(() => {
    const map = new Map<string, typeof screenIndex>();
    screenIndex.forEach((s) => {
      map.set(s.group, [...(map.get(s.group) ?? []), s]);
    });
    return [...map.entries()];
  }, []);

  const jump = (s: ScreenId) => {
    setStart(s);
    setLive(s);
    setSeq((n) => n + 1);
    setMode("prototype");
  };

  return (
    <div className="min-h-screen bg-[#08080c] text-white">
      {/* ambient background */}
      <div className="pointer-events-none fixed inset-0 overflow-hidden">
        <div className="absolute -left-40 top-[-10%] h-[520px] w-[520px] rounded-full bg-[#7b6cff]/18 blur-[140px]" />
        <div className="absolute right-[-10%] top-[30%] h-[460px] w-[460px] rounded-full bg-[#f0a561]/10 blur-[150px]" />
        <div className="absolute bottom-[-10%] left-1/3 h-[420px] w-[420px] rounded-full bg-[#4fd1b5]/10 blur-[150px]" />
        <div
          className="absolute inset-0 opacity-[0.16]"
          style={{
            backgroundImage:
              "linear-gradient(rgba(255,255,255,.07) 1px,transparent 1px),linear-gradient(90deg,rgba(255,255,255,.07) 1px,transparent 1px)",
            backgroundSize: "64px 64px",
            maskImage: "radial-gradient(ellipse at 50% 0%,black,transparent 72%)",
          }}
        />
      </div>

      {/* header */}
      <header className="relative z-10 border-b border-white/8 px-6 py-4 backdrop-blur-xl lg:px-10">
        <div className="mx-auto flex max-w-[1680px] flex-wrap items-center gap-x-6 gap-y-3">
          <div className="flex items-center gap-3">
            <div
              className="grid h-10 w-10 place-items-center rounded-[13px]"
              style={{
                background: "linear-gradient(145deg,#7b6cff,#2b2350)",
                boxShadow: "0 10px 26px -8px rgba(123,108,255,.8)",
              }}
            >
              <svg width="21" height="21" viewBox="0 0 24 24" fill="none">
                <path d="M6 19V5.6l3.4 1.2V19" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" />
                <path d="M14.6 19V8.4L18 9.6V19" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" opacity=".75" />
                <path d="M6 5.6 18 9.6" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" opacity=".5" />
              </svg>
            </div>
            <div>
              <h1 className="t-h2" style={{ fontFamily: '"Plus Jakarta Sans",sans-serif' }}>
                LyraMusic <span className="text-white/35">· UI/UX Prototype V1</span>
              </h1>
              <p className="t-meta text-white/45">
                Local-first music player · 30 screens · interactive · Flutter-ready spec
              </p>
            </div>
          </div>

          <div className="ml-auto flex flex-wrap items-center gap-3">
            <div className="flex rounded-full border border-white/10 bg-white/5 p-1">
              {(["prototype", "gallery"] as const).map((m) => (
                <button
                  key={m}
                  onClick={() => setMode(m)}
                  className="t-button rounded-full px-4 py-1.5 capitalize transition"
                  style={{
                    background: mode === m ? "#fff" : "transparent",
                    color: mode === m ? "#0b0b11" : "rgba(255,255,255,.6)",
                  }}
                >
                  {m === "prototype" ? "Prototype" : "All screens"}
                </button>
              ))}
            </div>

            <div className="flex items-center gap-1.5 rounded-full border border-white/10 bg-white/5 p-1.5">
              {themeList
                .filter((t) => t.id !== "system")
                .map((t) => (
                  <button
                    key={t.id}
                    onClick={() => setTheme(t.id)}
                    title={t.label}
                    aria-label={t.label}
                    className="h-6 w-6 rounded-full border transition"
                    style={{
                      background:
                        t.id === "light"
                          ? "#faf8f5"
                          : t.id === "graphite"
                          ? "#2b2e34"
                          : t.id === "amber"
                          ? "#e2974a"
                          : t.id === "bloom"
                          ? "#e8719c"
                          : "#7b6cff",
                      borderColor: theme === t.id ? "#fff" : "transparent",
                      transform: theme === t.id ? "scale(1.12)" : "scale(1)",
                    }}
                  />
                ))}
            </div>
          </div>
        </div>
      </header>

      {mode === "prototype" ? (
        <main className="relative z-10 mx-auto flex max-w-[1680px] gap-8 px-6 py-8 lg:px-10">
          {/* screen index */}
          <aside className="hidden w-[232px] shrink-0 xl:block">
            <div className="sticky top-6 max-h-[calc(100vh-6rem)] overflow-y-auto no-bar pr-1">
              <p className="t-label mb-3 text-white/35">Screens · 30</p>
              <div className="space-y-5">
                {groups.map(([group, items]) => (
                  <div key={group}>
                    <p className="t-label mb-1.5 text-white/30">{group}</p>
                    <div className="space-y-0.5">
                      {items.map((s) => {
                        const active = live === s.id;
                        return (
                          <button
                            key={s.id}
                            onClick={() => jump(s.id)}
                            className="flex w-full items-center gap-2 rounded-[11px] px-2.5 py-2 text-left transition"
                            style={{
                              background: active ? "rgba(123,108,255,.18)" : "transparent",
                              color: active ? "#fff" : "rgba(255,255,255,.55)",
                              boxShadow: active ? "inset 0 0 0 1px rgba(123,108,255,.5)" : "none",
                            }}
                          >
                            <span className="t-tech text-white/30">{s.n}</span>
                            <span className="t-meta font-medium">{s.label}</span>
                          </button>
                        );
                      })}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </aside>

          {/* phone */}
          <section className="flex flex-1 flex-col items-center">
            <div className="mb-5 flex flex-wrap items-center justify-center gap-2 xl:hidden">
              {screenIndex.slice(0, 12).map((s) => (
                <button
                  key={s.id}
                  onClick={() => jump(s.id)}
                  className="t-meta rounded-full border border-white/12 bg-white/5 px-3 py-1.5 text-white/70"
                >
                  {s.label}
                </button>
              ))}
            </div>

            <Phone
              key={`${start}-${seq}`}
              screen={start}
              theme={theme}
              setTheme={setTheme}
              onNavigate={setLive}
            />

            <p className="t-meta mt-5 max-w-sm text-center text-white/40">
              Fully interactive — play, favourite, reorder the queue by dragging, edit tags, switch
              themes and explore every state.
            </p>
          </section>

          {/* design system panel */}
          <aside className="hidden w-[310px] shrink-0 space-y-4 2xl:block">
            <div className="sticky top-6 space-y-4">
              <div className="rounded-[20px] border border-white/10 bg-white/[0.04] p-4">
                <p className="t-label mb-3 text-white/35">Product principle</p>
                <p className="t-body text-white/80">
                  “Internet enriches LyraMusic, but it is never required for the core music
                  experience.”
                </p>
                <div className="mt-3 flex flex-wrap gap-1.5">
                  {["Local-first", "Offline", "Fast", "Elegant", "Personal"].map((t) => (
                    <span key={t} className="t-meta rounded-full bg-white/8 px-2.5 py-1 text-white/60">
                      {t}
                    </span>
                  ))}
                </div>
              </div>

              <div className="rounded-[20px] border border-white/10 bg-white/[0.04] p-4">
                <p className="t-label mb-3 text-white/35">Colour tokens</p>
                <div className="grid grid-cols-2 gap-2">
                  {tokens.map(([name, hex, v]) => (
                    <div key={name} className="flex items-center gap-2 rounded-[10px] bg-white/[0.04] p-2">
                      <span
                        className="h-6 w-6 shrink-0 rounded-[7px] border border-white/15"
                        style={{ background: v }}
                      />
                      <span className="min-w-0">
                        <span className="t-meta block truncate text-white/80">{name}</span>
                        <span className="t-tech block text-white/35">{hex}</span>
                      </span>
                    </div>
                  ))}
                </div>
                <p className="t-meta mt-2 text-white/35">Swatches follow the selected theme.</p>
              </div>

              <div className="rounded-[20px] border border-white/10 bg-white/[0.04] p-4">
                <p className="t-label mb-3 text-white/35">Type scale</p>
                <div className="space-y-1.5">
                  <p className="t-display">Display 30</p>
                  <p className="t-h1">Heading 24</p>
                  <p className="t-h2">Heading 18</p>
                  <p className="t-title">Song title 14.5</p>
                  <p className="t-body text-white/60">Body 13.5 · artist, album</p>
                  <p className="t-meta text-white/45">Meta 12 · secondary info</p>
                  <p className="t-tech text-white/40">TECH 11 · 320 kbps · 4:18</p>
                </div>
                <p className="t-meta mt-3 text-white/35">
                  Plus Jakarta Sans for headings · Inter for UI · JetBrains Mono for technical data.
                </p>
              </div>

              <div className="rounded-[20px] border border-white/10 bg-white/[0.04] p-4">
                <p className="t-label mb-3 text-white/35">Key flows</p>
                <div className="space-y-3">
                  {flows.map((f) => (
                    <div key={f.label}>
                      <p className="t-meta mb-1.5 font-semibold text-white/70">{f.label}</p>
                      <div className="flex flex-wrap items-center gap-1">
                        {f.steps.map((st, i) => (
                          <span key={st.s} className="flex items-center gap-1">
                            <button
                              onClick={() => jump(st.s)}
                              className="t-meta rounded-full border border-white/12 bg-white/5 px-2.5 py-1 text-white/70 transition hover:border-[#7b6cff] hover:text-white"
                            >
                              {st.t}
                            </button>
                            {i < f.steps.length - 1 && <span className="text-white/25">→</span>}
                          </span>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <div className="rounded-[20px] border border-white/10 bg-white/[0.04] p-4">
                <p className="t-label mb-2 text-white/35">Spec notes</p>
                <ul className="t-meta space-y-1.5 text-white/55">
                  <li>• Radius 10 / 14 / 18 / 24 / 30 px</li>
                  <li>• Grid 4 px · screen padding 20 px</li>
                  <li>• Touch targets ≥ 44 px</li>
                  <li>• Icons 16 / 18 / 20 / 22 px, 1.7 stroke</li>
                  <li>• Motion 140–300 ms, cubic-bezier(.22,.9,.3,1)</li>
                  <li>• Never colour-only state: icon + label always</li>
                </ul>
              </div>
            </div>
          </aside>
        </main>
      ) : (
        <main className="relative z-10 mx-auto max-w-[1680px] px-6 py-8 lg:px-10">
          {groups.map(([group, items]) => (
            <section key={group} className="mb-12">
              <div className="mb-5 flex items-center gap-3">
                <h2 className="t-h2" style={{ fontFamily: '"Plus Jakarta Sans",sans-serif' }}>
                  {group}
                </h2>
                <span className="t-meta rounded-full bg-white/8 px-2.5 py-1 text-white/50">
                  {items.length} screens
                </span>
                <div className="h-px flex-1 bg-white/10" />
              </div>
              <div className="flex flex-wrap gap-8">
                {items.map((s) => (
                  <button key={s.id} onClick={() => jump(s.id)} className="group text-left">
                    <div className="transition-transform duration-300 group-hover:-translate-y-1.5">
                      <Phone
                        screen={s.id}
                        theme={theme}
                        setTheme={setTheme}
                        frozen
                        scale={0.46}
                        label={`${s.n} · ${s.label}`}
                      />
                    </div>
                  </button>
                ))}
              </div>
            </section>
          ))}
        </main>
      )}

      <footer className="relative z-10 border-t border-white/8 px-6 py-6 text-center lg:px-10">
        <p className="t-meta text-white/35">
          LyraMusic V1 — local music player. No accounts, no streaming, no advertising, no
          mandatory cloud. Designed for Flutter implementation.
        </p>
      </footer>
    </div>
  );
}
