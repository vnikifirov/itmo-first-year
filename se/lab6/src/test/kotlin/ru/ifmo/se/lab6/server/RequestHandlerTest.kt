package ru.ifmo.se.lab6.server

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.junit.jupiter.api.Assertions.assertEquals

@ExtendWith(MockitoExtension::class)
class RequestHandlerTest {
  @Test
  fun `responds with 400 for invalid requests`() {
    val response = readResponseWithQueue("{invalid request", queue())
    assertEquals("""{"status":400""" +
      ""","data":"Unable to parse the request; please make sure the data you are sending is valid JSON"}""" + '\n', response)
  }

  @Test
  fun `responds with 422 for unknown commands`() {
    val response = readResponseWithQueue("""{"action":"die"}""", queue())
    assertEquals("""{"status":422,"data":"Unknown command \"die\""}""" + '\n', response)
  }

  @Test
  fun `responds with 422 for commands missing a payload`() {
    val response = readResponseWithQueue("""{"action":"add"}""", queue())
    assertEquals("""{"status":422,"data":"Command \"add\" requires an argument specified in the \"payload\" field"}""" + '\n', response)
  }

  @Test
  fun `responds with 422 for deserialization errors`() {
    val response = readResponseWithQueue("""{"action":"add","payload":{"status":"Processing"}}""", queue())
    assertEquals("""{"status":422,"data":"Request payload is invalid: applicant name cannot be blank"}""" + '\n', response)
  }

  @Test
  fun `responds with a list of commands for list_commands`() {
    val response = readResponseWithQueue("""{"action":"list_commands"}""", queue())
    assertEquals("""{"status":200,"data":[{"name":"clear","argument":"none"},{"name":"add","argument":"json"},""" +
      """{"name":"add_if_max","argument":"json"},{"name":"add_if_min","argument":"json"},{"name":"remove_lower","argument":"json"},""" +
      """{"name":"remove_greater","argument":"json"},{"name":"remove_first","argument":"none"},{"name":"remove_last","argument":"none"},""" +
      """{"name":"remove","argument":"json"},{"name":"remove_all","argument":"json"},{"name":"info","argument":"none"},""" +
      """{"name":"dump_queue","argument":"none"},{"name":"argument_schema","argument":"none"}]}""" + '\n', response)
  }
}
