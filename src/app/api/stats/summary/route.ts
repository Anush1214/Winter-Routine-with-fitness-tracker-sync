import { NextRequest, NextResponse } from "next/server";
import { getSummaryStats } from "@/backend/services/statsService";

export const dynamic = "force-dynamic";

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get("userId") || "default_hunter";

    const stats = await getSummaryStats(userId);
    return NextResponse.json({
      success: true,
      userId,
      ...stats,
    });
  } catch (error: unknown) {
    console.error("GET /api/stats/summary error:", error);
    return NextResponse.json(
      { success: false, error: (error as Error).message },
      { status: 500 }
    );
  }
}
