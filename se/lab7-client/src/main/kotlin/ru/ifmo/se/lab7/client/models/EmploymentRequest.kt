package ru.ifmo.se.lab7.client.models

import javafx.beans.property.SimpleDoubleProperty
import javafx.beans.property.SimpleIntegerProperty

import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import ru.ifmo.se.lab7.client.LocaleControl
import tornadofx.*
import java.time.*
import java.time.format.DateTimeFormatter.ISO_DATE_TIME
import java.time.format.DateTimeFormatter.ISO_ZONED_DATE_TIME
import javax.json.*

class EmploymentRequest(
  id: Int = 0,
  applicant: String = "",
  locLatitude: Double = 0.0,
  locLongitude: Double = 0.0,
  date: LocalDate = LocalDate.now(),
  details: String = "",
  status: Status = Status.PROCESSING,
  colorCode: ColorCode = ColorCode.ORANGE
): JsonModel, Comparable<EmploymentRequest> {
  val idProperty = SimpleIntegerProperty(this, "id", id)
  var id by idProperty

  val applicantProperty = SimpleStringProperty(this, "applicant", applicant)
  var applicant by applicantProperty

  val locLatitudeProperty = SimpleDoubleProperty(this, "locLatitude", locLatitude)
  var locLatitude by locLatitudeProperty

  val locLongitudeProperty = SimpleDoubleProperty(this, "locLongitude", locLongitude)
  var locLongitude by locLongitudeProperty

  val dateProperty = SimpleObjectProperty<LocalDate>(this, "date", date)
  var date by dateProperty

  val detailsProperty = SimpleStringProperty(this, "details", details)
  var details by detailsProperty

  val statusProperty = SimpleObjectProperty<Status>(this, "status", status)
  var status by statusProperty

  val colorCodeProperty = SimpleObjectProperty<ColorCode>(this, "colorCode", colorCode)
  var colorCode by colorCodeProperty

  override fun updateModel(json: JsonObject) = with(json) {
    id = int("id")!!
    applicant = string("applicant")
    date = LocalDate.parse(string("date"), ISO_DATE_TIME)
    locLatitude = double("locLatitude") ?: 0.0
    locLongitude = double("locLongitude") ?: 0.0
    details = string("details")
    status = string("status")?.let(Status::valueOf) ?: Status.PROCESSING
    colorCode = string("colorCode")?.let(ColorCode::valueOf) ?: ColorCode.ORANGE
  }

  override fun toJSON(json: JsonBuilder) {
    with(json) {
      add("id", id)
      add("applicant", applicant)
      add("date", ISO_ZONED_DATE_TIME.format(ZonedDateTime.of(LocalDateTime.of(date, LocalTime.MIDNIGHT), ZoneId.systemDefault())))
      add("locLatitude", locLatitude)
      add("locLongitude", locLongitude)
      add("details", details)
      add("status", status.name)
      add("colorCode", colorCode.name)
    }
  }

  enum class Status {
    INTERVIEW_SCHEDULED, PROCESSING, REJECTED;

    override fun toString() = LocaleControl.string("enum.status." + this.name.toLowerCase())
  }

  enum class ColorCode {
    ORANGE, BLUE, GREEN;

    override fun toString() = LocaleControl.string("enum.color_code." + this.name.toLowerCase())
  }

  override fun compareTo(other: EmploymentRequest): Int =
    Comparator.comparing<EmploymentRequest, Status> { it.status }
      .thenComparing<LocalDate> { it.date }
      .reversed().compare(this, other)
}

class EmploymentRequestModel(var employmentRequest: EmploymentRequest): ViewModel() {
  val id           = bind { employmentRequest.idProperty }
  val applicant    = bind { employmentRequest.applicantProperty }
  val locLatitude  = bind { employmentRequest.locLatitudeProperty }
  val locLongitude = bind { employmentRequest.locLongitudeProperty }
  val date         = bind { employmentRequest.dateProperty }
  val details      = bind { employmentRequest.detailsProperty }
  val status       = bind { employmentRequest.statusProperty }
  val colorCode    = bind { employmentRequest.colorCodeProperty }
}
