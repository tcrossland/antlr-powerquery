package io.truedat.csv

import java.io.File

import kantan.csv.CsvConfiguration.{ Header, QuotePolicy }
import kantan.csv._
import kantan.csv.ops._
import org.apache.commons.lang3.StringUtils

class Writer(val path: String, val ou: String, val reportName: String, val group: String = "-", val system: String = "PowerBI", val namespace: String = "pbi://") {

  case class Structure(name: String, externalId: String, `type`: String, system: String = system, ou: String = ou, group: String = reportName, description: String = "")

  // system, group, external_id, name, field_name, type, description, nullable, precision
  case class Field(parentName: String, parentId: String, fieldName: String, system: String = system, group: String = reportName, `type`: String = "Field", nullable: String = "")

  // system, parent_group, parent_external_id, parent_name, child_group, child_external_id, child_name
  case class Relation(parentId: String, parentName: String, childId: String, childName: String, system: String = system, parentGroup: String = reportName, childGroup: String = reportName)

  implicit val structureEncoder: HeaderEncoder[Structure] =
    HeaderEncoder.caseEncoder("name", "external_id", "type", "system", "ou", "group", "description")(Structure.unapply)

  implicit val fieldEncoder: HeaderEncoder[Field] =
    HeaderEncoder.caseEncoder("name", "external_id", "field_name", "system", "group", "type", "nullable")(Field.unapply)

  implicit val relationEncoder: HeaderEncoder[Relation] =
    HeaderEncoder.caseEncoder("parent_external_id", "parent_name", "child_external_id", "child_name", "system", "parent_group", "child_group")(Relation.unapply)

  def normalize: String => String = s => StringUtils.stripAccents(s.toLowerCase).replaceAll(" ", "_")

  val reportId: String = normalize(reportName)
  val separator: String = "/"

  def mkExternalId(args: String*): String = namespace + args.toList.map(normalize).mkString(separator)

  def createStructure: String => String => Structure = `type` => name => Structure(name, mkExternalId(reportName, name), `type`)

  def createReport: Structure = Structure(reportName, mkExternalId(reportName), "Report")

  def createTable: String => Structure = name => Structure(name, mkExternalId(reportName, name), "Table")

  def createField: (String, String) => Field = (tableName, fieldName) => Field(tableName, mkExternalId(reportName, tableName), fieldName)

  def createRelation: Structure => Structure => Relation = parent => child => Relation(parent.externalId, parent.name, child.externalId, child.name)

  def write: List[(String, Set[String])] => Unit = tablesWithFields => {
    val dirName = path + "/" + normalize(reportName)

    val dir = new File(dirName)
    if (!dir.exists() && !dir.mkdir()) {
      // Unable to create directory
    } else {
      val structures = createReport :: tablesWithFields.map(_._1).map(createTable(_)).sortBy(_.externalId)
      val fields = tablesWithFields.flatMap(tf => tf._2.map(f => createField(tf._1, f))).sortBy(f => mkExternalId(f.parentId, f.fieldName))
      val relations = structures.tail.map(createRelation(structures.head)).sortBy(r => mkExternalId(r.parentId, r.childId))
      val config = CsvConfiguration(';', '"', QuotePolicy.Always, Header.Implicit)

      new File(dirName + "/structures.csv").asCsvWriter[Structure](config).write(structures).close()

      new File(dirName + "/fields.csv").asCsvWriter[Field](config).write(fields).close()

      new File(dirName + "/relations.csv").asCsvWriter[Relation](config).write(relations).close()
    }
  }

}