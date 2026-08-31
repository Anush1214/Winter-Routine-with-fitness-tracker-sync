import { NextResponse } from "next/server";
import { getHeatmapMatrix } from "@/backend/services/statsService";

export const dynamic = "force-dynamic";

export async function GET() {
  try {
    const days = await getHeatmapMatrix();
    return NextResponse.json({ success: true, days });
  } catch (error: unknown) {
    console.error("GET /api/stats/heatmap error:", error);
    return NextResponse.json(
      { success: false, error: (error as Error).message },
      { status: 500 }
    );
  }
}
