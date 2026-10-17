import { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from "react";
import type { ReactNode } from "react";
import { Icon } from "./icons";
import type { IconName } from "./icons";
import type { ScreenId, Song } from "./data";

/* ============================================================
   NAVIGATION / APP STATE CONTEXT (one per phone frame)
   ============================================================ */

export type SheetId = "menu" | "addToPlaylist" | "sort" | "sleep" | null;

type LyraState = {
  screen: ScreenId;
  go: (s: ScreenId) => void;
  back: () => void;
  sheet: SheetId;
  openSheet: (s: SheetId) => void;
  closeSheet: () => void;
  playing: boolean;
  setPlaying: (v: boolean) => void;
  current: Song;
  play: (s: Song) => void;
  favs: string[];
  toggleFav: (id: string) => void;
  online: boolean;
  setOnline: (v: boolean) => void;
  toast: string | null;
  notify: (msg: string) => void;
  theme: string;
  setTheme: (t: string) => void;
  frozen: boolean;
};

const Ctx = createContext<LyraState | null>(null);
export const useLyra = () => useContext(Ctx) as LyraState;

export function LyraProvider({
  children,
  initial,
  theme,
  setTheme,
  frozen = false,
  startSong,
  onNavigate,
}: {
  children: ReactNode;
  initial: ScreenId;
  theme: string;
  setTheme: (t: string) => void;
  frozen?: boolean;
  startSong: Song;
  onNavigate?: (s: ScreenId) => void;
}) {
  const [stack, setStack] = useState<ScreenId[]>([initial]);
  const [sheet, setSheet] = useState<SheetId>(null);
  const [playing, setPlaying] = useState(true);
  const [current, setCurrent] = useState<Song>(startSong);
  const [favs, setFavs] = useState<string[]>(["s1", "s5", "s9"]);
  const [online, setOnline] = useState(true);
  const [toast, setToast] = useState<string | null>(null);
  const timer = useRef<number | undefined>(undefined);

  const notify = useCallback((msg: string) => {
    setToast(msg);
    window.clearTimeout(timer.current);
    timer.current = window.setTimeout(() => setToast(null), 2200);
  }, []);

  const screen = stack[stack.length - 1];
  useEffect(() => {
    onNavigate?.(screen);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [screen]);

  const value = useMemo<LyraState>(
    () => ({
      screen,
      go: (s) => {
        if (frozen) return;
        setSheet(null);
        setStack((st) => (st[st.length - 1] === s ? st : [...st, s].slice(-12)));
      },
      back: () => setStack((st) => (st.length > 1 ? st.slice(0, -1) : st)),
      sheet,
      openSheet: (s) => setSheet(s),
      closeSheet: () => setSheet(null),
      playing,
      setPlaying,
      current,
      play: (s) => {
        setCurrent(s);
        setPlaying(true);
      },
      favs,
      toggleFav: (id) =>
        setFavs((f) => (f.includes(id) ? f.filter((x) => x !== id) : [...f, id])),
      online,
      setOnline,
      toast,
      notify,
      theme,
      setTheme,
      frozen,
    }),
    [stack, sheet, playing, current, favs, online, toast, notify, theme, setTheme, frozen]
  );

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

/* ============================================================
   ARTWORK
   ============================================================ */

const gradients = [
  "linear-gradient(140deg,#4c3ba8,#1d1838)",
  "linear-gradient(140deg,#1f5f6b,#10212e)",
  "linear-gradient(140deg,#7a4a1f,#2a1710)",
  "linear-gradient(140deg,#2f4a7a,#141c2e)",
  "linear-gradient(140deg,#2d6b4f,#121f1a)",
];

export function Art({
  src,
  size = 48,
  radius = 14,
  alt = "",
  className = "",
  seed = 0,
  glow = false,
}: {
  src?: string | null;
  size?: number | string;
  radius?: number;
  alt?: string;
  className?: string;
  seed?: number;
  glow?: boolean;
}) {
  const [failed, setFailed] = useState(false);
  const fill = size === "fill";
  const dim = typeof size === "number" ? `${size}px` : fill ? "100%" : (size as string);
  const show = src && !failed;

  return (
    <div
      className={`relative shrink-0 overflow-hidden ${className}`}
      style={{
        width: dim,
        height: typeof size === "number" ? dim : fill ? "100%" : undefined,
        aspectRatio: typeof size === "number" || fill ? undefined : "1 / 1",
        borderRadius: radius,
        background: show ? "var(--surface-2)" : gradients[seed % gradients.length],
        boxShadow: glow
          ? "0 24px 60px -18px rgba(0,0,0,.8), inset 0 0 0 1px rgba(255,255,255,.07)"
          : "inset 0 0 0 1px rgba(255,255,255,.06)",
      }}
    >
      {show ? (
        <img
          src={src as string}
          alt={alt}
          loading="lazy"
          onError={() => setFailed(true)}
          className="h-full w-full object-cover"
        />
      ) : (
        <div className="grid h-full w-full place-items-center text-white/45">
          <Icon name="note" size={Math.max(14, Math.min(44, (typeof size === "number" ? size : 120) * 0.38))} />
        </div>
      )}
    </div>
  );
}

/* Stacked 2x2 playlist mosaic */
export function Mosaic({ art, size = 72, radius = 16 }: { art: string[]; size?: number | string; radius?: number }) {
  const dim = typeof size === "number" ? `${size}px` : size;
  return (
    <div
      className="grid shrink-0 grid-cols-2 overflow-hidden"
      style={{
        width: dim,
        height: typeof size === "number" ? dim : undefined,
        aspectRatio: typeof size === "number" ? undefined : "1 / 1",
        borderRadius: radius,
        boxShadow: "inset 0 0 0 1px rgba(255,255,255,.07)",
      }}
    >
      {art.slice(0, 4).map((a, i) => (
        <Art key={i} src={a} size="100%" radius={0} seed={i} />
      ))}
    </div>
  );
}

/* ============================================================
   BUTTONS
   ============================================================ */

export function Button({
  children,
  variant = "primary",
  icon,
  onClick,
  full = false,
  size = "md",
  tone,
  className = "",
}: {
  children?: ReactNode;
  variant?: "primary" | "secondary" | "ghost" | "danger";
  icon?: IconName;
  onClick?: () => void;
  full?: boolean;
  size?: "sm" | "md";
  tone?: string;
  className?: string;
}) {
  const base =
    "press t-button inline-flex items-center justify-center gap-2 rounded-full outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]";
  const sizes = size === "sm" ? "h-9 px-3.5" : "h-11 px-5";
  const styles: Record<string, string> = {
    primary: "text-[var(--on-primary)] shadow-[0_8px_24px_-8px_rgba(0,0,0,.6)]",
    secondary: "text-[var(--text)] bg-[var(--surface-2)] border border-[var(--divider)]",
    ghost: "text-[var(--text-2)] hover:text-[var(--text)]",
    danger: "text-[var(--error)] bg-[color-mix(in_srgb,var(--error)_12%,transparent)]",
  };
  return (
    <button
      onClick={onClick}
      className={`${base} ${sizes} ${styles[variant]} ${full ? "w-full" : ""} ${className}`}
      style={variant === "primary" ? { background: tone ?? "var(--primary)" } : undefined}
    >
      {icon && <Icon name={icon} size={16} filled={icon === "play"} />}
      {children}
    </button>
  );
}

export function IconBtn({
  name,
  label,
  onClick,
  active = false,
  size = 20,
  box = 38,
  tone,
  surface = false,
}: {
  name: IconName;
  label: string;
  onClick?: () => void;
  active?: boolean;
  size?: number;
  box?: number;
  tone?: string;
  surface?: boolean;
}) {
  return (
    <button
      aria-label={label}
      aria-pressed={active}
      onClick={onClick}
      style={{ width: box, height: box, color: active ? tone ?? "var(--primary)" : "var(--text-2)" }}
      className={`press grid place-items-center rounded-full outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] ${
        surface ? "border border-[var(--divider)] bg-[var(--surface-2)]" : ""
      }`}
    >
      <Icon name={name} size={size} filled={active && name === "heart"} />
    </button>
  );
}

export function ActionIcon({
  name,
  label,
  onClick,
  active,
  box = 38,
  size = 20,
}: {
  name: IconName;
  label: string;
  onClick?: () => void;
  active?: boolean;
  box?: number;
  size?: number;
}) {
  return (
    <button
      aria-label={label}
      onClick={onClick}
      style={{ width: box, height: box, color: active ? "var(--primary)" : "var(--text-2)" }}
      className="press grid place-items-center rounded-full outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]"
    >
      <Icon name={name} size={size} filled={!!active && name === "heart"} />
    </button>
  );
}

/* ============================================================
   STRUCTURE
   ============================================================ */

export function AppBar({
  title,
  subtitle,
  onBack,
  right,
  large = false,
  transparent = false,
}: {
  title: string;
  subtitle?: string;
  onBack?: () => void;
  right?: ReactNode;
  large?: boolean;
  transparent?: boolean;
}) {
  return (
    <div
      className={`sticky top-0 z-20 -mx-5 flex items-center gap-2 px-5 pb-2 pt-3 ${
        transparent ? "" : "glass bg-[color-mix(in_srgb,var(--bg)_82%,transparent)]"
      }`}
    >
      {onBack && (
        <button
          aria-label="Back"
          onClick={onBack}
          className="press -ml-2 grid h-9 w-9 place-items-center rounded-full text-[var(--text)]"
        >
          <Icon name="chevronLeft" size={22} />
        </button>
      )}
      <div className="min-w-0 flex-1">
        {subtitle && <p className="t-label text-[var(--text-3)]">{subtitle}</p>}
        <h1 className={`${large ? "t-h1" : "t-h2"} clamp-1 text-[var(--text)]`}>{title}</h1>
      </div>
      {right}
    </div>
  );
}

export function SectionHead({
  title,
  action,
  onAction,
}: {
  title: string;
  action?: string;
  onAction?: () => void;
}) {
  return (
    <div className="mb-3 flex items-baseline justify-between gap-3">
      <h2 className="t-h3 text-[var(--text)]">{title}</h2>
      {action && (
        <button onClick={onAction} className="press t-meta font-semibold text-[var(--text-2)]">
          {action}
        </button>
      )}
    </div>
  );
}

export function Card({
  children,
  className = "",
  pad = true,
  onClick,
}: {
  children: ReactNode;
  className?: string;
  pad?: boolean;
  onClick?: () => void;
}) {
  const Tag = onClick ? "button" : "div";
  return (
    <Tag
      onClick={onClick}
      className={`block w-full rounded-[var(--r-lg)] border border-[var(--divider)] bg-[var(--surface)] text-left ${
        pad ? "p-4" : ""
      } ${onClick ? "press" : ""} ${className}`}
    >
      {children}
    </Tag>
  );
}

export function Chip({
  children,
  active = false,
  onClick,
  icon,
}: {
  children: ReactNode;
  active?: boolean;
  onClick?: () => void;
  icon?: IconName;
}) {
  return (
    <button
      onClick={onClick}
      className={`press t-meta inline-flex h-8 shrink-0 items-center gap-1.5 rounded-full border px-3 font-semibold ${
        active
          ? "border-transparent bg-[var(--text)] text-[var(--bg)]"
          : "border-[var(--divider)] bg-[var(--surface)] text-[var(--text-2)]"
      }`}
    >
      {icon && <Icon name={icon} size={13} />}
      {children}
    </button>
  );
}

export function Toggle({ on, onChange }: { on: boolean; onChange?: (v: boolean) => void }) {
  return (
    <button
      role="switch"
      aria-checked={on}
      onClick={() => onChange?.(!on)}
      className="press relative h-[26px] w-[44px] shrink-0 rounded-full border transition-colors"
      style={{
        background: on ? "var(--primary)" : "var(--surface-2)",
        borderColor: on ? "transparent" : "var(--divider-strong)",
      }}
    >
      <span
        className="absolute top-[3px] h-[18px] w-[18px] rounded-full bg-white shadow transition-all"
        style={{ left: on ? 23 : 3 }}
      />
    </button>
  );
}

export function Progress({ value, height = 4, tone }: { value: number; height?: number; tone?: string }) {
  return (
    <div
      className="w-full overflow-hidden rounded-full"
      style={{ height, background: "var(--divider-strong)" }}
      role="progressbar"
      aria-valuenow={Math.round(value)}
    >
      <div
        className="h-full rounded-full transition-[width] duration-500"
        style={{ width: `${value}%`, background: tone ?? "var(--primary)" }}
      />
    </div>
  );
}

export function Scrubber({ value, onChange }: { value: number; onChange?: (v: number) => void }) {
  return (
    <div className="relative flex h-6 items-center">
      <div className="absolute inset-x-0 h-1 overflow-hidden rounded-full bg-[var(--divider-strong)]">
        <div className="h-full rounded-full bg-[var(--text)]" style={{ width: `${value}%` }} />
      </div>
      <div
        className="absolute h-3 w-3 -translate-x-1/2 rounded-full bg-[var(--text)] shadow"
        style={{ left: `${value}%` }}
      />
      <input
        type="range"
        min={0}
        max={100}
        value={value}
        onChange={(e) => onChange?.(Number(e.target.value))}
        aria-label="Seek"
        className="absolute inset-0 h-6 w-full cursor-pointer opacity-0"
      />
    </div>
  );
}

export function Divider() {
  return <div className="h-px w-full bg-[var(--divider)]" />;
}

export function Badge({ children, tone = "neutral" }: { children: ReactNode; tone?: "neutral" | "accent" | "warn" | "ok" | "err" }) {
  const map = {
    neutral: "text-[var(--text-2)] bg-[var(--surface-2)] border-[var(--divider)]",
    accent: "text-[var(--primary)] bg-[var(--primary-soft)] border-transparent",
    warn: "text-[var(--warning)] bg-[color-mix(in_srgb,var(--warning)_14%,transparent)] border-transparent",
    ok: "text-[var(--success)] bg-[color-mix(in_srgb,var(--success)_14%,transparent)] border-transparent",
    err: "text-[var(--error)] bg-[color-mix(in_srgb,var(--error)_14%,transparent)] border-transparent",
  };
  return (
    <span
      className={`t-label inline-flex h-[20px] items-center rounded-full border px-2 tracking-[0.1em] ${map[tone]}`}
    >
      {children}
    </span>
  );
}

export function Banner({
  icon,
  title,
  text,
  action,
  onAction,
  tone = "info",
}: {
  icon: IconName;
  title: string;
  text?: string;
  action?: string;
  onAction?: () => void;
  tone?: "info" | "warn" | "err" | "ok";
}) {
  const colors = {
    info: "var(--primary)",
    warn: "var(--warning)",
    err: "var(--error)",
    ok: "var(--success)",
  }[tone];
  return (
    <div
      className="flex gap-3 rounded-[var(--r-md)] border p-3"
      style={{
        borderColor: `color-mix(in srgb, ${colors} 28%, transparent)`,
        background: `color-mix(in srgb, ${colors} 9%, transparent)`,
      }}
    >
      <span style={{ color: colors }} className="mt-px shrink-0">
        <Icon name={icon} size={17} />
      </span>
      <div className="min-w-0 flex-1">
        <p className="t-title text-[var(--text)]">{title}</p>
        {text && <p className="t-meta mt-0.5 text-[var(--text-2)]">{text}</p>}
        {action && (
          <button onClick={onAction} className="press t-meta mt-2 font-bold" style={{ color: colors }}>
            {action} →
          </button>
        )}
      </div>
    </div>
  );
}

export function EmptyState({
  icon,
  title,
  text,
  action,
  onAction,
  secondary,
  compact = false,
}: {
  icon: IconName;
  title: string;
  text: string;
  action?: string;
  onAction?: () => void;
  secondary?: string;
  compact?: boolean;
}) {
  return (
    <div
      className={`flex flex-col items-center rounded-[var(--r-lg)] border border-dashed border-[var(--divider-strong)] bg-[var(--surface)] px-5 text-center ${
        compact ? "py-6" : "py-10"
      }`}
    >
      <div
        className="grid place-items-center rounded-full"
        style={{
          width: compact ? 44 : 56,
          height: compact ? 44 : 56,
          background: "var(--primary-soft)",
          color: "var(--primary)",
        }}
      >
        <Icon name={icon} size={compact ? 20 : 24} />
      </div>
      <h3 className="t-h3 mt-3 text-[var(--text)]">{title}</h3>
      <p className="t-meta mt-1 max-w-[16rem] text-[var(--text-2)]">{text}</p>
      {action && (
        <div className="mt-4 flex flex-wrap items-center justify-center gap-2">
          <Button size="sm" onClick={onAction}>
            {action}
          </Button>
          {secondary && (
            <Button size="sm" variant="ghost">
              {secondary}
            </Button>
          )}
        </div>
      )}
    </div>
  );
}

/* ============================================================
   LISTS
   ============================================================ */

export function TrackRow({
  song,
  index,
  onPlay,
  onMenu,
  playingNow = false,
  trailing,
  showArt = true,
  dense = false,
}: {
  song: Song;
  index?: number;
  onPlay?: () => void;
  onMenu?: () => void;
  playingNow?: boolean;
  trailing?: ReactNode;
  showArt?: boolean;
  dense?: boolean;
}) {
  return (
    <div className="group flex items-center gap-3">
      <button
        onClick={onPlay}
        className="press -mx-1 flex min-w-0 flex-1 items-center gap-3 rounded-[var(--r-md)] px-1 py-1.5 text-left"
      >
        {typeof index === "number" && (
          <span className="t-tech w-5 shrink-0 text-right text-[var(--text-3)]">{index}</span>
        )}
        {showArt && (
          <div className="relative">
            <Art src={song.art} size={dense ? 40 : 46} radius={12} seed={index ?? 0} />
            {playingNow && (
              <span className="absolute inset-0 grid place-items-center rounded-[12px] bg-black/55">
                <EqBars />
              </span>
            )}
          </div>
        )}
        <span className="min-w-0 flex-1">
          <span
            className="t-title clamp-1 block"
            style={{ color: playingNow ? "var(--primary)" : "var(--text)" }}
          >
            {song.title}
          </span>
          <span className="t-meta clamp-1 mt-0.5 flex items-center gap-1.5 text-[var(--text-2)]">
            {song.incomplete && (
              <Icon name="alert" size={11} className="shrink-0 text-[var(--warning)]" />
            )}
            {song.artist} · {song.album}
          </span>
        </span>
      </button>
      {trailing ?? (
        <>
          <span className="t-tech text-[var(--text-3)]">{song.duration}</span>
          <button
            aria-label={`More options for ${song.title}`}
            onClick={onMenu}
            className="press grid h-9 w-9 shrink-0 place-items-center rounded-full text-[var(--text-3)]"
          >
            <Icon name="more" size={18} />
          </button>
        </>
      )}
    </div>
  );
}

export function EqBars({ color = "#fff" }: { color?: string }) {
  return (
    <span className="flex h-4 items-end gap-[2px]">
      {[0, 1, 2].map((i) => (
        <span
          key={i}
          className="eq-bar block w-[2.5px] rounded-full"
          style={{ height: 14, background: color, animationDelay: `${i * 160}ms` }}
        />
      ))}
    </span>
  );
}

export function SettingRow({
  icon,
  title,
  value,
  onClick,
  right,
  tone,
}: {
  icon?: IconName;
  title: string;
  value?: string;
  onClick?: () => void;
  right?: ReactNode;
  tone?: string;
}) {
  const Tag = onClick ? "button" : "div";
  return (
    <Tag
      onClick={onClick}
      className={`flex w-full items-center gap-3 px-4 py-3 text-left ${onClick ? "press" : ""}`}
    >
      {icon && (
        <span
          className="grid h-8 w-8 shrink-0 place-items-center rounded-[10px]"
          style={{ background: "var(--surface-2)", color: tone ?? "var(--text-2)" }}
        >
          <Icon name={icon} size={16} />
        </span>
      )}
      <span className="min-w-0 flex-1">
        <span className="t-title clamp-1 block text-[var(--text)]">{title}</span>
        {value && <span className="t-meta clamp-1 block text-[var(--text-2)]">{value}</span>}
      </span>
      {right ?? <Icon name="chevronRight" size={16} className="shrink-0 text-[var(--text-3)]" />}
    </Tag>
  );
}

export function Group({ title, children }: { title?: string; children: ReactNode }) {
  return (
    <section>
      {title && <p className="t-label mb-2 px-1 text-[var(--text-3)]">{title}</p>}
      <div className="divide-y divide-[var(--divider)] overflow-hidden rounded-[var(--r-lg)] border border-[var(--divider)] bg-[var(--surface)]">
        {children}
      </div>
    </section>
  );
}

/* ============================================================
   SHEETS & OVERLAYS
   ============================================================ */

export function Sheet({
  open,
  onClose,
  children,
  title,
}: {
  open: boolean;
  onClose: () => void;
  children: ReactNode;
  title?: string;
}) {
  if (!open) return null;
  return (
    <div className="absolute inset-0 z-40 flex flex-col justify-end">
      <button
        aria-label="Close"
        onClick={onClose}
        className="a-scrim absolute inset-0"
        style={{ background: "var(--overlay)" }}
      />
      <div className="a-sheet relative max-h-[78%] overflow-y-auto rounded-t-[26px] border-t border-[var(--divider-strong)] bg-[var(--elevated)] pb-5 shadow-[0_-20px_60px_-20px_rgba(0,0,0,.8)]">
        <div className="sticky top-0 z-10 flex justify-center bg-[var(--elevated)] pb-1 pt-2.5">
          <span className="h-1 w-9 rounded-full bg-[var(--divider-strong)]" />
        </div>
        {title && <p className="t-label px-5 pb-2 pt-1 text-[var(--text-3)]">{title}</p>}
        {children}
      </div>
    </div>
  );
}

export function Toast({ message }: { message: string | null }) {
  if (!message) return null;
  return (
    <div className="pointer-events-none absolute inset-x-0 bottom-[150px] z-50 flex justify-center px-6">
      <div className="a-fade glass flex items-center gap-2 rounded-full border border-[var(--divider-strong)] bg-[color-mix(in_srgb,var(--elevated)_88%,transparent)] px-4 py-2.5 shadow-xl">
        <Icon name="check" size={14} className="text-[var(--success)]" />
        <span className="t-meta font-semibold text-[var(--text)]">{message}</span>
      </div>
    </div>
  );
}
