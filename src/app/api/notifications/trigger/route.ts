import { NextRequest, NextResponse } from "next/server";
import { triggerScheduledNotification } from "@/backend/services/notificationService";
import { formatDateKey } from "@/frontend/lib/utils";

export const dynamic = "force-dynamic";

export async function POST(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const slot = (searchParams.get("slot") || "morning").toLowerCase();
    const targetDateParam = searchParams.get("date") || formatDateKey(new Date());

    const authHeader = request.headers.get("Authorization");
    const cronSecret = process.env.CRON_SECRET;

    if (cronSecret) {
      const token = authHeader?.replace(/^Bearer\s+/i, "");
      if (token !== cronSecret) {
        return NextResponse.json(
          { success: false, error: "Unauthorized: Invalid or missing CRON_SECRET" },
          { status: 401 }
        );
      }
    }

    const appUrl = process.env.NEXT_PUBLIC_APP_URL || request.nextUrl.origin;
    const result = await triggerScheduledNotification(slot, targetDateParam, appUrl);

    return NextResponse.json(result);
  } catch (error: unknown) {
    console.error("POST /api/notifications/trigger error:", error);
    return NextResponse.json(
      { success: false, error: (error as Error).message },
      { status: 500 }
    );
  }
}
