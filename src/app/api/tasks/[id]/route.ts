import { NextRequest, NextResponse } from "next/server";
import { updateTask, deleteTask } from "@/backend/services/tasksService";

export const dynamic = "force-dynamic";

export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params;
    const body = await request.json();
    const { isCompleted, title, category, startTime, autoMetric } = body;

    const updateData: Record<string, unknown> = {};
    if (isCompleted !== undefined) updateData.isCompleted = Boolean(isCompleted);
    if (title !== undefined) updateData.title = title;
    if (category !== undefined) updateData.category = category;
    if (startTime !== undefined) updateData.startTime = startTime;
    if (autoMetric !== undefined) updateData.autoMetric = autoMetric;

    const updated = await updateTask(id, updateData);
    if (!updated) {
      return NextResponse.json(
        { success: false, error: "Task not found" },
        { status: 404 }
      );
    }

    return NextResponse.json({ success: true, task: updated });
  } catch (error: unknown) {
    console.error("PATCH /api/tasks/[id] error:", error);
    return NextResponse.json(
      { success: false, error: (error as Error).message },
      { status: 500 }
    );
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params;
    const { searchParams } = new URL(request.url);
    const deleteAllRecurring = searchParams.get("all") === "true";
    const fromDate = searchParams.get("fromDate") || undefined;

    const result = await deleteTask(id, deleteAllRecurring, fromDate);
    return NextResponse.json({ success: true, ...result });
  } catch (error: unknown) {
    console.error("DELETE /api/tasks/[id] error:", error);
    return NextResponse.json(
      { success: false, error: (error as Error).message },
      { status: 500 }
    );
  }
}
