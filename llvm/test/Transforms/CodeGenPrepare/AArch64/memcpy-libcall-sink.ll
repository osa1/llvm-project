; RUN: llc -mtriple=arm64-apple-macosx -stop-after=codegenprepare -o - %s | FileCheck %s

declare void @llvm.memcpy.p0.p0.i64(ptr nocapture writeonly, ptr nocapture readonly, i64, i1 immarg)

; CHECK-LABEL: @loop_libcall(
; CHECK: entry:
; CHECK-NEXT:   %dst = getelementptr i8, ptr %p, i64 %offset
; CHECK-NEXT:   br label %loop
; CHECK: loop:
; CHECK-NOT: sunkaddr
; CHECK: call void @llvm.memcpy{{.*}}(ptr {{[^,]*}}%dst,
define void @loop_libcall(ptr %p, i64 %offset, ptr %src, i64 %n, i32 %iters) {
entry:
  %dst = getelementptr i8, ptr %p, i64 %offset
  br label %loop

loop:
  %k = phi i32 [ 0, %entry ], [ %k.next, %loop ]
  call void @llvm.memcpy.p0.p0.i64(ptr %dst, ptr %src, i64 %n, i1 false)
  %k.next = add i32 %k, 1
  %cond = icmp ult i32 %k.next, %iters
  br i1 %cond, label %loop, label %exit

exit:
  ret void
}
