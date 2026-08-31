import { NextRequest, NextResponse } from "next/server";
import { processHealthSync } from "@/backend/services/healthSyncService";
import { formatDateKey } from "@/frontend/lib/utils";

export const dynamic = "force-dynamic";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const {
      date = formatDateKey(new Date()),
      steps = 0,
      sleepMinutes = 0,
      gymWorkoutDone = false,
      waterIntakeMl = 0,
    } = body;

    const result = await processHealthSync({
      date,
      steps,
      sleepMinutes,
      gymWorkoutDone,
      waterIntakeMl,
    });

    return NextResponse.json({
      success: true,
      message: "Smartwatch health metrics synced & tasks updated",
      ...result,
    });
  } catch (error: unknown) {
    console.error("POST /api/sync-health error:", error);
    return NextResponse.json(
      { success: false, error: (error as Error).message },
      { status: 500 }
    );
  }
}
