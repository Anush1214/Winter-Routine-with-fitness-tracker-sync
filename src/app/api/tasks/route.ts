import { NextRequest, NextResponse } from "next/server";
import { getTasksAndHealth, createTask } from "@/backend/services/tasksService";
import { formatDateKey } from "@/frontend/lib/utils";

export const dynamic = "force-dynamic";

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const dateParam = searchParams.get("date") || formatDateKey(new Date());

    const result = await getTasksAndHealth(dateParam);
    return NextResponse.json({
      success: true,
      date: dateParam,
      tasks: result.tasks,
      healthLog: result.healthLog,
    });
  } catch (error: unknown) {
    console.error("GET /api/tasks error:", error);
    return NextResponse.json(
      { success: false, error: (error as Error).message },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const {
      title,
      category = "routine",
      targetDate = formatDateKey(new Date()),
      startTime = null,
      autoMetric = null,
      applyScope = "today",
    } = body;

    if (!title || typeof title !== "string") {
      return NextResponse.json(
        { success: false, error: "Title is required" },
        { status: 400 }
      );
    }

    const result = await createTask({
      title,
      category,
      targetDate,
      startTime,
      autoMetric,
      applyScope,
    });

    return NextResponse.json({
      success: true,
      ...result,
      message: `Task applied with scope: ${applyScope}`,
    });
  } catch (error: unknown) {
    console.error("POST /api/tasks error:", error);
    return NextResponse.json(
      { success: false, error: (error as Error).message },
      { status: 500 }
    );
  }
}
