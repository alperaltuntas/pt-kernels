; ModuleID = '/glade/scratch/altuntas/target_subroutine-696200.ll'
source_filename = "/glade/scratch/altuntas/target_subroutine-696200.ll"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.C312_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant float 0xC008A2BE00000000
@.C308_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant float 0x4088B3C720000000
@.C309_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant float 0xC01FF00C60000000
@.C310_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant float 0x3FAA51F4A0000000
@.C307_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant float 0x4104CFAA60000000
@.C311_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant float 0xC06CC6E7E0000000
@.C306_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant float 0xC0C2D5BE40000000
@.C302_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant float 0x414AD43B80000000
@.C303_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant float 0xC0E38B6480000000
@.C304_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant float 0x406A0DFD80000000
@.C301_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant float 0x41C141FDA0000000
@.C305_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant float 0x412223CDA0000000
@.C300_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant float 0xBE7DDEA4A0000000
@.C298_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant float 0x3F47209DA0000000
@.C299_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant float 0x3E975B2C00000000
@.C285_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant i32 1
@.C348_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant i64 8
@.C286_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant i64 1
@.C347_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant i64 11
@.C346_target_subroutine_mod_calculate_density_array_wright_noref_ = internal constant i64 12

; Function Attrs: noinline
define float @target_subroutine_mod_() #0 {
.L.entry:
  ret float undef
}

define void @target_subroutine_mod_calculate_density_array_wright_noref_(i64* %t, i64* %s, i64* %pressure, i64* %rho, i64* %start, i64* %npts, i64* %"t$sd", i64* %"s$sd", i64* %"pressure$sd", i64* %"rho$sd") !dbg !5 {
L.entry:
  %z_b_1_320 = alloca i64, align 8
  %z_b_3_322 = alloca i64, align 8
  %z_b_5_324 = alloca i64, align 8
  %z_b_7_326 = alloca i64, align 8
  %z_b_9_328 = alloca i64, align 8
  %z_b_11_330 = alloca i64, align 8
  %z_b_13_332 = alloca i64, align 8
  %z_b_15_334 = alloca i64, align 8
  %.dY0001_352 = alloca i32, align 4
  %j_339 = alloca i32, align 4
  %al0_336 = alloca float, align 4
  %p0_337 = alloca float, align 4
  %lambda_338 = alloca float, align 4
  %0 = bitcast i64* %"t$sd" to i8*, !dbg !18
  %1 = getelementptr i8, i8* %0, i64 88, !dbg !18
  %2 = bitcast i8* %1 to i64*, !dbg !18
  %3 = load i64, i64* %2, align 8, !dbg !18
  store i64 %3, i64* %z_b_1_320, align 8, !dbg !18
  %4 = bitcast i64* %"t$sd" to i8*, !dbg !18
  %5 = getelementptr i8, i8* %4, i64 56, !dbg !18
  %6 = bitcast i8* %5 to i64*, !dbg !18
  %7 = load i64, i64* %6, align 8, !dbg !18
  %8 = bitcast i64* %"t$sd" to i8*, !dbg !18
  %9 = getelementptr i8, i8* %8, i64 80, !dbg !18
  %10 = bitcast i8* %9 to i64*, !dbg !18
  %11 = load i64, i64* %10, align 8, !dbg !18
  %12 = sub nsw i64 %11, 1, !dbg !18
  %13 = add nsw i64 %7, %12, !dbg !18
  store i64 %13, i64* %z_b_3_322, align 8, !dbg !18
  %14 = bitcast i64* %"s$sd" to i8*, !dbg !18
  %15 = getelementptr i8, i8* %14, i64 88, !dbg !18
  %16 = bitcast i8* %15 to i64*, !dbg !18
  %17 = load i64, i64* %16, align 8, !dbg !18
  store i64 %17, i64* %z_b_5_324, align 8, !dbg !18
  %18 = bitcast i64* %"s$sd" to i8*, !dbg !18
  %19 = getelementptr i8, i8* %18, i64 56, !dbg !18
  %20 = bitcast i8* %19 to i64*, !dbg !18
  %21 = load i64, i64* %20, align 8, !dbg !18
  %22 = bitcast i64* %"s$sd" to i8*, !dbg !18
  %23 = getelementptr i8, i8* %22, i64 80, !dbg !18
  %24 = bitcast i8* %23 to i64*, !dbg !18
  %25 = load i64, i64* %24, align 8, !dbg !18
  %26 = sub nsw i64 %25, 1, !dbg !18
  %27 = add nsw i64 %21, %26, !dbg !18
  store i64 %27, i64* %z_b_7_326, align 8, !dbg !18
  %28 = bitcast i64* %"pressure$sd" to i8*, !dbg !18
  %29 = getelementptr i8, i8* %28, i64 88, !dbg !18
  %30 = bitcast i8* %29 to i64*, !dbg !18
  %31 = load i64, i64* %30, align 8, !dbg !18
  store i64 %31, i64* %z_b_9_328, align 8, !dbg !18
  %32 = bitcast i64* %"pressure$sd" to i8*, !dbg !18
  %33 = getelementptr i8, i8* %32, i64 56, !dbg !18
  %34 = bitcast i8* %33 to i64*, !dbg !18
  %35 = load i64, i64* %34, align 8, !dbg !18
  %36 = bitcast i64* %"pressure$sd" to i8*, !dbg !18
  %37 = getelementptr i8, i8* %36, i64 80, !dbg !18
  %38 = bitcast i8* %37 to i64*, !dbg !18
  %39 = load i64, i64* %38, align 8, !dbg !18
  %40 = sub nsw i64 %39, 1, !dbg !18
  %41 = add nsw i64 %35, %40, !dbg !18
  store i64 %41, i64* %z_b_11_330, align 8, !dbg !18
  %42 = bitcast i64* %"rho$sd" to i8*, !dbg !18
  %43 = getelementptr i8, i8* %42, i64 88, !dbg !18
  %44 = bitcast i8* %43 to i64*, !dbg !18
  %45 = load i64, i64* %44, align 8, !dbg !18
  store i64 %45, i64* %z_b_13_332, align 8, !dbg !18
  %46 = bitcast i64* %"rho$sd" to i8*, !dbg !18
  %47 = getelementptr i8, i8* %46, i64 56, !dbg !18
  %48 = bitcast i8* %47 to i64*, !dbg !18
  %49 = load i64, i64* %48, align 8, !dbg !18
  %50 = bitcast i64* %"rho$sd" to i8*, !dbg !18
  %51 = getelementptr i8, i8* %50, i64 80, !dbg !18
  %52 = bitcast i8* %51 to i64*, !dbg !18
  %53 = load i64, i64* %52, align 8, !dbg !18
  %54 = sub nsw i64 %53, 1, !dbg !18
  %55 = add nsw i64 %49, %54, !dbg !18
  store i64 %55, i64* %z_b_15_334, align 8, !dbg !18
  br label %L.LB2_391

L.LB2_391:                                        ; preds = %L.entry
  %56 = bitcast i64* %start to i32*, !dbg !20
  %57 = load i32, i32* %56, align 4, !dbg !20
  %58 = bitcast i64* %npts to i32*, !dbg !20
  %59 = load i32, i32* %58, align 4, !dbg !20
  %60 = add nsw i32 %57, %59, !dbg !20
  %61 = bitcast i64* %start to i32*, !dbg !20
  %62 = load i32, i32* %61, align 4, !dbg !20
  %63 = sub nsw i32 %60, %62, !dbg !20
  store i32 %63, i32* %.dY0001_352, align 4, !dbg !20
  %64 = bitcast i64* %start to i32*, !dbg !20
  %65 = load i32, i32* %64, align 4, !dbg !20
  store i32 %65, i32* %j_339, align 4, !dbg !20
  %66 = load i32, i32* %.dY0001_352, align 4, !dbg !20
  %67 = icmp sle i32 %66, 0, !dbg !20
  br i1 %67, label %L.LB2_351, label %L.LB2_350, !dbg !20

L.LB2_350:                                        ; preds = %L.LB2_350, %L.LB2_391
  %68 = load i32, i32* %j_339, align 4, !dbg !21
  %69 = sext i32 %68 to i64, !dbg !21
  %70 = load i64, i64* %z_b_7_326, align 8, !dbg !21
  %71 = add nsw i64 %69, %70, !dbg !21
  %72 = bitcast i64* %s to i8*, !dbg !21
  %73 = getelementptr i8, i8* %72, i64 -4, !dbg !21
  %74 = bitcast i8* %73 to float*, !dbg !21
  %75 = getelementptr float, float* %74, i64 %71, !dbg !21
  %76 = load float, float* %75, align 4, !dbg !21
  %77 = fmul fast float %76, 0xBE7DDEA4A0000000, !dbg !21
  %78 = load i32, i32* %j_339, align 4, !dbg !21
  %79 = sext i32 %78 to i64, !dbg !21
  %80 = load i64, i64* %z_b_3_322, align 8, !dbg !21
  %81 = add nsw i64 %79, %80, !dbg !21
  %82 = bitcast i64* %t to i8*, !dbg !21
  %83 = getelementptr i8, i8* %82, i64 -4, !dbg !21
  %84 = bitcast i8* %83 to float*, !dbg !21
  %85 = getelementptr float, float* %84, i64 %81, !dbg !21
  %86 = load float, float* %85, align 4, !dbg !21
  %87 = fmul fast float %86, 0x3E975B2C00000000, !dbg !21
  %88 = fadd fast float %87, 0x3F47209DA0000000, !dbg !21
  %89 = fadd fast float %77, %88, !dbg !21
  store float %89, float* %al0_336, align 4, !dbg !21
  %90 = load i32, i32* %j_339, align 4, !dbg !22
  %91 = sext i32 %90 to i64, !dbg !22
  %92 = load i64, i64* %z_b_3_322, align 8, !dbg !22
  %93 = add nsw i64 %91, %92, !dbg !22
  %94 = bitcast i64* %t to i8*, !dbg !22
  %95 = getelementptr i8, i8* %94, i64 -4, !dbg !22
  %96 = bitcast i8* %95 to float*, !dbg !22
  %97 = getelementptr float, float* %96, i64 %93, !dbg !22
  %98 = load float, float* %97, align 4, !dbg !22
  %99 = load i32, i32* %j_339, align 4, !dbg !22
  %100 = sext i32 %99 to i64, !dbg !22
  %101 = load i64, i64* %z_b_7_326, align 8, !dbg !22
  %102 = add nsw i64 %100, %101, !dbg !22
  %103 = bitcast i64* %s to i8*, !dbg !22
  %104 = getelementptr i8, i8* %103, i64 -4, !dbg !22
  %105 = bitcast i8* %104 to float*, !dbg !22
  %106 = getelementptr float, float* %105, i64 %102, !dbg !22
  %107 = load float, float* %106, align 4, !dbg !22
  %108 = fmul fast float %107, 0xC0C2D5BE40000000, !dbg !22
  %109 = load i32, i32* %j_339, align 4, !dbg !22
  %110 = sext i32 %109 to i64, !dbg !22
  %111 = load i64, i64* %z_b_3_322, align 8, !dbg !22
  %112 = add nsw i64 %110, %111, !dbg !22
  %113 = bitcast i64* %t to i8*, !dbg !22
  %114 = getelementptr i8, i8* %113, i64 -4, !dbg !22
  %115 = bitcast i8* %114 to float*, !dbg !22
  %116 = getelementptr float, float* %115, i64 %112, !dbg !22
  %117 = load float, float* %116, align 4, !dbg !22
  %118 = load i32, i32* %j_339, align 4, !dbg !22
  %119 = sext i32 %118 to i64, !dbg !22
  %120 = load i64, i64* %z_b_3_322, align 8, !dbg !22
  %121 = add nsw i64 %119, %120, !dbg !22
  %122 = bitcast i64* %t to i8*, !dbg !22
  %123 = getelementptr i8, i8* %122, i64 -4, !dbg !22
  %124 = bitcast i8* %123 to float*, !dbg !22
  %125 = getelementptr float, float* %124, i64 %121, !dbg !22
  %126 = load float, float* %125, align 4, !dbg !22
  %127 = fmul fast float %126, 0x406A0DFD80000000, !dbg !22
  %128 = fadd fast float %127, 0xC0E38B6480000000, !dbg !22
  %129 = fmul fast float %117, %128, !dbg !22
  %130 = fadd fast float %129, 0x414AD43B80000000, !dbg !22
  %131 = fadd fast float %108, %130, !dbg !22
  %132 = fmul fast float %98, %131, !dbg !22
  %133 = load i32, i32* %j_339, align 4, !dbg !22
  %134 = sext i32 %133 to i64, !dbg !22
  %135 = load i64, i64* %z_b_7_326, align 8, !dbg !22
  %136 = add nsw i64 %134, %135, !dbg !22
  %137 = bitcast i64* %s to i8*, !dbg !22
  %138 = getelementptr i8, i8* %137, i64 -4, !dbg !22
  %139 = bitcast i8* %138 to float*, !dbg !22
  %140 = getelementptr float, float* %139, i64 %136, !dbg !22
  %141 = load float, float* %140, align 4, !dbg !22
  %142 = fmul fast float %141, 0x412223CDA0000000, !dbg !22
  %143 = fadd fast float %142, 0x41C141FDA0000000, !dbg !22
  %144 = fadd fast float %132, %143, !dbg !22
  store float %144, float* %p0_337, align 4, !dbg !22
  %145 = load i32, i32* %j_339, align 4, !dbg !23
  %146 = sext i32 %145 to i64, !dbg !23
  %147 = load i64, i64* %z_b_3_322, align 8, !dbg !23
  %148 = add nsw i64 %146, %147, !dbg !23
  %149 = bitcast i64* %t to i8*, !dbg !23
  %150 = getelementptr i8, i8* %149, i64 -4, !dbg !23
  %151 = bitcast i8* %150 to float*, !dbg !23
  %152 = getelementptr float, float* %151, i64 %148, !dbg !23
  %153 = load float, float* %152, align 4, !dbg !23
  %154 = load i32, i32* %j_339, align 4, !dbg !23
  %155 = sext i32 %154 to i64, !dbg !23
  %156 = load i64, i64* %z_b_7_326, align 8, !dbg !23
  %157 = add nsw i64 %155, %156, !dbg !23
  %158 = bitcast i64* %s to i8*, !dbg !23
  %159 = getelementptr i8, i8* %158, i64 -4, !dbg !23
  %160 = bitcast i8* %159 to float*, !dbg !23
  %161 = getelementptr float, float* %160, i64 %157, !dbg !23
  %162 = load float, float* %161, align 4, !dbg !23
  %163 = fmul fast float %162, 0xC008A2BE00000000, !dbg !23
  %164 = load i32, i32* %j_339, align 4, !dbg !23
  %165 = sext i32 %164 to i64, !dbg !23
  %166 = load i64, i64* %z_b_3_322, align 8, !dbg !23
  %167 = add nsw i64 %165, %166, !dbg !23
  %168 = bitcast i64* %t to i8*, !dbg !23
  %169 = getelementptr i8, i8* %168, i64 -4, !dbg !23
  %170 = bitcast i8* %169 to float*, !dbg !23
  %171 = getelementptr float, float* %170, i64 %167, !dbg !23
  %172 = load float, float* %171, align 4, !dbg !23
  %173 = load i32, i32* %j_339, align 4, !dbg !23
  %174 = sext i32 %173 to i64, !dbg !23
  %175 = load i64, i64* %z_b_3_322, align 8, !dbg !23
  %176 = add nsw i64 %174, %175, !dbg !23
  %177 = bitcast i64* %t to i8*, !dbg !23
  %178 = getelementptr i8, i8* %177, i64 -4, !dbg !23
  %179 = bitcast i8* %178 to float*, !dbg !23
  %180 = getelementptr float, float* %179, i64 %176, !dbg !23
  %181 = load float, float* %180, align 4, !dbg !23
  %182 = fmul fast float %181, 0x3FAA51F4A0000000, !dbg !23
  %183 = fadd fast float %182, 0xC01FF00C60000000, !dbg !23
  %184 = fmul fast float %172, %183, !dbg !23
  %185 = fadd fast float %184, 0x4088B3C720000000, !dbg !23
  %186 = fadd fast float %163, %185, !dbg !23
  %187 = fmul fast float %153, %186, !dbg !23
  %188 = load i32, i32* %j_339, align 4, !dbg !23
  %189 = sext i32 %188 to i64, !dbg !23
  %190 = load i64, i64* %z_b_7_326, align 8, !dbg !23
  %191 = add nsw i64 %189, %190, !dbg !23
  %192 = bitcast i64* %s to i8*, !dbg !23
  %193 = getelementptr i8, i8* %192, i64 -4, !dbg !23
  %194 = bitcast i8* %193 to float*, !dbg !23
  %195 = getelementptr float, float* %194, i64 %191, !dbg !23
  %196 = load float, float* %195, align 4, !dbg !23
  %197 = fmul fast float %196, 0xC06CC6E7E0000000, !dbg !23
  %198 = fadd fast float %197, 0x4104CFAA60000000, !dbg !23
  %199 = fadd fast float %187, %198, !dbg !23
  store float %199, float* %lambda_338, align 4, !dbg !23
  %200 = load i32, i32* %j_339, align 4, !dbg !24
  %201 = sext i32 %200 to i64, !dbg !24
  %202 = load i64, i64* %z_b_11_330, align 8, !dbg !24
  %203 = add nsw i64 %201, %202, !dbg !24
  %204 = bitcast i64* %pressure to i8*, !dbg !24
  %205 = getelementptr i8, i8* %204, i64 -4, !dbg !24
  %206 = bitcast i8* %205 to float*, !dbg !24
  %207 = getelementptr float, float* %206, i64 %203, !dbg !24
  %208 = load float, float* %207, align 4, !dbg !24
  %209 = load float, float* %p0_337, align 4, !dbg !24
  %210 = fadd fast float %208, %209, !dbg !24
  %211 = load i32, i32* %j_339, align 4, !dbg !24
  %212 = sext i32 %211 to i64, !dbg !24
  %213 = load i64, i64* %z_b_11_330, align 8, !dbg !24
  %214 = add nsw i64 %212, %213, !dbg !24
  %215 = bitcast i64* %pressure to i8*, !dbg !24
  %216 = getelementptr i8, i8* %215, i64 -4, !dbg !24
  %217 = bitcast i8* %216 to float*, !dbg !24
  %218 = getelementptr float, float* %217, i64 %214, !dbg !24
  %219 = load float, float* %218, align 4, !dbg !24
  %220 = load float, float* %p0_337, align 4, !dbg !24
  %221 = fadd fast float %219, %220, !dbg !24
  %222 = load float, float* %al0_336, align 4, !dbg !24
  %223 = fmul fast float %221, %222, !dbg !24
  %224 = load float, float* %lambda_338, align 4, !dbg !24
  %225 = fadd fast float %223, %224, !dbg !24
  %226 = fdiv fast float %210, %225, !dbg !24
  %227 = load i32, i32* %j_339, align 4, !dbg !24
  %228 = sext i32 %227 to i64, !dbg !24
  %229 = load i64, i64* %z_b_15_334, align 8, !dbg !24
  %230 = add nsw i64 %228, %229, !dbg !24
  %231 = bitcast i64* %rho to i8*, !dbg !24
  %232 = getelementptr i8, i8* %231, i64 -4, !dbg !24
  %233 = bitcast i8* %232 to float*, !dbg !24
  %234 = getelementptr float, float* %233, i64 %230, !dbg !24
  store float %226, float* %234, align 4, !dbg !24
  %235 = load i32, i32* %j_339, align 4, !dbg !25
  %236 = add nsw i32 %235, 1, !dbg !25
  store i32 %236, i32* %j_339, align 4, !dbg !25
  %237 = load i32, i32* %.dY0001_352, align 4, !dbg !25
  %238 = sub nsw i32 %237, 1, !dbg !25
  store i32 %238, i32* %.dY0001_352, align 4, !dbg !25
  %239 = load i32, i32* %.dY0001_352, align 4, !dbg !25
  %240 = icmp sgt i32 %239, 0, !dbg !25
  br i1 %240, label %L.LB2_350, label %L.LB2_351, !dbg !25

L.LB2_351:                                        ; preds = %L.LB2_350, %L.LB2_391
  ret void, !dbg !26
}

attributes #0 = { noinline }

!llvm.module.flags = !{!0, !1}
!llvm.dbg.cu = !{!2}

!0 = !{i32 2, !"Dwarf Version", i32 4}
!1 = !{i32 2, !"Debug Info Version", i32 3}
!2 = distinct !DICompileUnit(language: DW_LANG_Fortran90, file: !3, producer: " F90 Flang - 1.5 2017-05-01", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !4, globals: !4, imports: !4)
!3 = !DIFile(filename: "target_subroutine.F90", directory: "/glade/work/altuntas/pt-kernels/calc_density_noref_gnu")
!4 = !{}
!5 = distinct !DISubprogram(name: "calculate_density_array_wright_noref", scope: !6, file: !3, line: 30, type: !7, isLocal: false, isDefinition: true, scopeLine: 30, isOptimized: false, unit: !2)
!6 = !DIModule(scope: !2, name: "target_subroutine_mod")
!7 = !DISubroutineType(types: !8)
!8 = !{null, !9, !9, !9, !9, !13, !13, !14, !14, !14, !14}
!9 = !DICompositeType(tag: DW_TAG_array_type, baseType: !10, size: 32, align: 32, elements: !11)
!10 = !DIBasicType(name: "real", size: 32, align: 32, encoding: DW_ATE_float)
!11 = !{!12}
!12 = !DISubrange(count: 0, lowerBound: 1)
!13 = !DIBasicType(name: "integer", size: 32, align: 32, encoding: DW_ATE_signed)
!14 = !DICompositeType(tag: DW_TAG_array_type, baseType: !15, size: 1024, align: 64, elements: !16)
!15 = !DIBasicType(name: "integer*8", size: 64, align: 64, encoding: DW_ATE_signed)
!16 = !{!17}
!17 = !DISubrange(count: 16, lowerBound: 1)
!18 = !DILocation(line: 30, column: 1, scope: !19)
!19 = !DILexicalBlock(scope: !5, file: !3, line: 30, column: 1)
!20 = !DILocation(line: 43, column: 1, scope: !19)
!21 = !DILocation(line: 44, column: 1, scope: !19)
!22 = !DILocation(line: 45, column: 1, scope: !19)
!23 = !DILocation(line: 46, column: 1, scope: !19)
!24 = !DILocation(line: 47, column: 1, scope: !19)
!25 = !DILocation(line: 48, column: 1, scope: !19)
!26 = !DILocation(line: 50, column: 1, scope: !19)
