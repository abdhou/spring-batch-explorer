package app.abdhou.core;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

public record PageRequest(
   @Min(0)
   int index,
   @Min(1) @Max(100)
   int size
) { }
