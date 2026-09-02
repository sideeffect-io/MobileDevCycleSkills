package example.http

sealed interface HttpResult {
    data class Success(val body: String) : HttpResult

    data object NotFound : HttpResult

    data object Unavailable : HttpResult
}

fun interface HttpDataClient {
    /** Implementations are main-safe and propagate coroutine cancellation. */
    suspend fun get(path: String): HttpResult
}
