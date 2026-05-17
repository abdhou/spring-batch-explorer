package app.abdhou;

import java.util.List;

public record Page<T>(
    List<T> elements,
    int index,
    int size,
    int totalElements
) { }
