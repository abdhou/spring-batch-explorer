package app.abdhou.core;

import jakarta.validation.ConstraintViolationException;
import org.hibernate.validator.internal.engine.path.PathImpl;
import org.jspecify.annotations.NonNull;
import org.springframework.http.*;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@RestControllerAdvice
public class ApiExceptionHandler extends ResponseEntityExceptionHandler {

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<Object> handleConstraintViolationException(ConstraintViolationException exception, WebRequest request) {

        Set<String> errors = exception.getConstraintViolations()
            .stream()
            .map(c -> ((PathImpl) c.getPropertyPath()).getLeafNode() + ": " + c.getMessage())
            .collect(Collectors.toSet());

        var problemDetail = ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST, "Invalid request content.");
        problemDetail.setProperty("errors", errors);

        return this.handleExceptionInternal(exception, problemDetail, new HttpHeaders(), HttpStatus.BAD_REQUEST, request);
    }

    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(
        MethodArgumentNotValidException ex,
        @NonNull HttpHeaders headers,
        @NonNull HttpStatusCode status,
        @NonNull WebRequest request) {

        var fieldErrors = ex
            .getBindingResult()
            .getFieldErrors()
            .stream()
            .map(error -> error.getField() + ": " + error.getDefaultMessage())
            .toList();

        var globalErrors = ex
            .getBindingResult()
            .getGlobalErrors()
            .stream()
            .map(error -> error.getObjectName() + ": " + error.getDefaultMessage()).toList();

        var errors = Stream.concat(fieldErrors.stream(), globalErrors.stream()).toList();
        var problemDetail = ex.getBody();
        problemDetail.setProperty("errors", errors);

        return handleExceptionInternal(ex, problemDetail, headers, status, request);
    }
}
