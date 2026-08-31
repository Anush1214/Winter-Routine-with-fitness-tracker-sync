import { NextRequest, NextResponse } from "next/server";
import { getUserSettings, updateUserSettings } from "@/backend/services/settingsService";

export const dynamic = "force-dynamic";

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get("userId") || "default_hunter";
    const settings = await getUserSettings(userId);
    return NextResponse.json({ success: true, settings });
  } catch (error: unknown) {
    console.error("GET /api/settings error:", error);
    return NextResponse.json(
      { success: false, error: (error as Error).message },
      { status: 500 }
    );
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const body = await request.json();
    const {
      ntfyTopic,
      ntfyServer,
      morningTime,
      morningEnabled,
      eveningTime,
      eveningEnabled,
      nightTime,
      nightEnabled,
      waterGoalMl,
      stepsGoal,
      sleepGoalMinutes,
      customSlots,
      userId = "default_hunter",
    } = body;

    const updates: Record<string, unknown> = {};
    if (ntfyTopic !== undefined) updates.ntfyTopic = ntfyTopic;
    if (ntfyServer !== undefined) updates.ntfyServer = ntfyServer;
    if (morningTime !== undefined) updates.morningTime = morningTime;
    if (morningEnabled !== undefined) updates.morningEnabled = Boolean(morningEnabled);
    if (eveningTime !== undefined) updates.eveningTime = eveningTime;
    if (eveningEnabled !== undefined) updates.eveningEnabled = Boolean(eveningEnabled);
    if (nightTime !== undefined) updates.nightTime = nightTime;
    if (nightEnabled !== undefined) updates.nightEnabled = Boolean(nightEnabled);
    if (waterGoalMl !== undefined) updates.waterGoalMl = Number(waterGoalMl);
    if (stepsGoal !== undefined) updates.stepsGoal = Number(stepsGoal);
    if (sleepGoalMinutes !== undefined) updates.sleepGoalMinutes = Number(sleepGoalMinutes);
    if (customSlots !== undefined) {
      updates.customSlots = typeof customSlots === "string" ? customSlots : JSON.stringify(customSlots);
    }

    const updated = await updateUserSettings(updates, userId);
    return NextResponse.json({ success: true, settings: updated });
  } catch (error: unknown) {
    console.error("PATCH /api/settings error:", error);
    return NextResponse.json(
      { success: false, error: (error as Error).message },
      { status: 500 }
    );
  }
}
