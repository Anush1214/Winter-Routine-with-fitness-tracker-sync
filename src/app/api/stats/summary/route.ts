import { NextResponse } from "next/server";
import { getSummaryStats } from "@/backend/services/statsService";

export const dynamic = "force-dynamic";

export async function GET() {
  try {
    const summary = await getSummaryStats();
    return NextResponse.json({ success: true, ...summary });
  } catch (error: unknown) {
    console.error("GET /api/stats/summary error:", error);
    return NextResponse.json(
      { success: false, error: (error as Error).message },
      { status: 500 }
    );
  }
}
