namespace Application.Common;

public enum OperationResult
{
    Success,
    NotFound,
    Conflict // Para la concurrencia optimista
}