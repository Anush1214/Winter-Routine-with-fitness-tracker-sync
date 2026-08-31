import { NextRequest, NextResponse } from "next/server";
import { processWaterIntake } from "@/backend/services/waterService";
import { formatDateKey } from "@/frontend/lib/utils";

export const dynamic = "force-dynamic";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const {
      date = formatDateKey(new Date()),
      amountMl = 250,
      mode = "increment",
      userId = "default_hunter",
    } = body;

    const result = await processWaterIntake({
      date,
      amountMl: Number(amountMl),
      mode,
      userId,
    });

    return NextResponse.json({
      success: true,
      userId,
      message: `Water intake updated: ${result.waterIntakeMl} ml`,
      ...result,
    });
  } catch (error: unknown) {
    console.error("POST /api/water-intake error:", error);
    return NextResponse.json(
      { success: false, error: (error as Error).message },
      { status: 500 }
    );
  }
}
