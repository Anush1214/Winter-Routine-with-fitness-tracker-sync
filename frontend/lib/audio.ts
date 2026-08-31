// frontend/lib/audio.ts - Custom User Sound Effects Engine

class AudioManager {
  private soundEnabled: boolean = false;
  private clickAudio: HTMLAudioElement | null = null;
  private winAudio: HTMLAudioElement | null = null;
  private robotAudio: HTMLAudioElement | null = null;

  constructor() {
    if (typeof window !== "undefined") {
      const stored = localStorage.getItem("winter_arc_sound");
      if (stored !== null) {
        this.soundEnabled = stored === "true";
      } else {
        this.soundEnabled = false;
      }
      try {
        this.clickAudio = new Audio("/sounds/click.wav");
        this.clickAudio.volume = 0.85;

        this.winAudio = new Audio("/sounds/win.wav");
        this.winAudio.volume = 0.9;

        this.robotAudio = new Audio("/sounds/robot_click.wav");
        this.robotAudio.volume = 0.85;
      } catch {}
    }
  }

  public isEnabled(): boolean {
    return this.soundEnabled;
  }

  public toggleSound(): boolean {
    this.soundEnabled = !this.soundEnabled;
    if (typeof window !== "undefined") {
      localStorage.setItem("winter_arc_sound", String(this.soundEnabled));
    }
    if (this.soundEnabled) {
      this.playRobotClick();
    }
    return this.soundEnabled;
  }

  /// 1. Custom Click (`mixkit-select-click-1109.wav`)
  public playClick() {
    if (!this.soundEnabled) return;
    this._play(this.clickAudio, "/sounds/click.wav", 180);
  }

  /// 2. Custom Win / Level Up (`mixkit-quick-win-video-game-notification-269.wav`)
  public playVictory() {
    if (!this.soundEnabled) return;
    this._play(this.winAudio, "/sounds/win.wav", 320);
  }

  public playLevelUp() {
    this.playVictory();
  }

  /// 3. Custom Sci-Fi Robot Click (`mixkit-sci-fi-interface-robot-click-901.wav`)
  public playRobotClick() {
    if (!this.soundEnabled) return;
    this._play(this.robotAudio, "/sounds/robot_click.wav", 240);
  }

  public playChime() {
    this.playRobotClick();
  }

  public playWaterDrop() {
    this.playClick();
  }

  public playPenaltyWarning() {
    this.playRobotClick();
  }

  private _play(audioElement: HTMLAudioElement | null, url: string, fallbackFreq: number) {
    if (typeof window === "undefined") return;
    try {
      if (audioElement) {
        audioElement.currentTime = 0;
        audioElement.play().catch(() => this._synthFallback(fallbackFreq));
      } else {
        const a = new Audio(url);
        a.volume = 0.85;
        a.play().catch(() => this._synthFallback(fallbackFreq));
      }
    } catch {
      this._synthFallback(fallbackFreq);
    }
  }

  private _synthFallback(freq: number) {
    try {
      const AudioCtx =
        window.AudioContext ||
        (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
      if (AudioCtx) {
        const ctx = new AudioCtx();
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = "triangle";
        osc.frequency.setValueAtTime(freq, ctx.currentTime);
        gain.gain.setValueAtTime(0.2, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.12);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start();
        osc.stop(ctx.currentTime + 0.12);
      }
    } catch {}
  }
}

export const audio = new AudioManager();
