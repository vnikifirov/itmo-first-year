package org.pearl

import kotlin.test.Test

import TestModel
import org.pearl.query.from
import org.pearl.repo.Repo
import kotlin.test.BeforeTest
import kotlin.test.assertEquals

class RepoTest {
  @BeforeTest
  fun init() {
    Repo.connectToUrl("localhost", 5432, dbname = "pearl", username = "pearl", password = "pearl")

    Repo.rawSqlUpdate("""DROP TABLE IF EXISTS "TestModel"""")
  }

  @Test
  fun `should create tables`() {
    Repo.createTable<TestModel>()
    assertEquals(emptyList(), Repo.fetchMany(from<TestModel>()))
  }

  @Test
  fun `should insert new records`() {
    try { Repo.createTable<TestModel>() } catch (e: Exception) { }
    assertEquals(1, Repo.insert(Changeset.newRecord<TestModel>(
      mapOf("name" to "aaa", "size" to "100", "enum" to "T2"), listOf("name", "size", "enum"))).id)
    assertEquals(2, Repo.insert(Changeset.newRecord<TestModel>(
      mapOf("name" to "bbb", "size" to "120", "enum" to "T3"), listOf("name", "size", "enum"))).id)

    assertEquals(listOf(1, 2), Repo.fetchMany(from<TestModel>().where { it["size"] lt 200 }).map { it.id })
    assertEquals(listOf(1), Repo.fetchMany(from<TestModel>().where { it["name"] eq "aaa" }).map { it.id })
    assertEquals(listOf(2), Repo.fetchMany(from<TestModel>().where { it["enum"] eq TestModel.TestEnum.T3 }).map { it.id })
  }
}
