; RUN: llc -mtriple=arm64-apple-macosx -stop-after=codegenprepare -o - %s | FileCheck %s

; CodegenPrepare tries to sink GEPs that can fold into a load or store
; instruction and become an addressing mode of the instruction. Test that it
; does the same for memory intrinsics that are compiled as inline instructions
; (rather than libcalls).

declare void @llvm.memcpy.p0.p0.i64(ptr nocapture writeonly, ptr nocapture readonly, i64, i1 immarg)

declare ptr @sink(ptr) local_unnamed_addr

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

; CHECK-LABEL: @loop_inline(
; CHECK: entry:
; CHECK-NEXT:   %t = alloca [40 x i8], align 8
; CHECK-NEXT:   br label %body
; CHECK: body:
; CHECK:   %sunkaddr = getelementptr inbounds i8, ptr %t, i64 16
; CHECK:   %sunkaddr{{[0-9]+}} = getelementptr i8, ptr %p3, i64 40
; CHECK:   %sunkaddr{{[0-9]+}} = getelementptr i8, ptr %p2, i64 48
define void @loop_inline(ptr captures(none) %src, ptr readonly captures(none) %p2, ptr writeonly captures(none) initializes((40, 41)) %p3) local_unnamed_addr #1 {
entry:
  %t = alloca [40 x i8], align 8
  %t_plus_16 = getelementptr inbounds nuw i8, ptr %t, i64 16
  %g1 = getelementptr i8, ptr %p3, i64 40
  %g2 = getelementptr i8, ptr %p2, i64 48
  br label %body

body:
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %t, ptr noundef nonnull align 1 dereferenceable(16) %src, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %t_plus_16, ptr noundef nonnull align 1 dereferenceable(24) %src, i64 24, i1 false)
  store i8 0, ptr %g1, align 8
  %v = load i8, ptr %g2, align 1
  store i8 %v, ptr %src, align 1
  %0 = call ptr @sink(ptr nonnull %t)
  br label %body
}
