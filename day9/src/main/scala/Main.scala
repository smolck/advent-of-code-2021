import scala.io.Source
import scala.collection.mutable.ArrayBuffer
import util.control.Breaks._

object Main extends App {
  val input = Source
    .fromFile("input.txt")
    .getLines
    .toVector
    .map(_.map(_.toString.toInt).toVector)

  // Surround with values to make this easier.
  val thing = 15
  val things = Vector.fill(input(0).length)(15)
  val nums = input
    .prepended(things)
    .appended(things)
    .map(_.prepended(thing).appended(thing))

  def partOne(): Unit = {
    var risks = ArrayBuffer[Int]()
    for (row <- 1 to nums.length - 2) {
      for (col <- 1 to nums(0).length - 2) {
        val above = nums(row - 1)(col)
        val below = nums(row + 1)(col)
        val right = nums(row)(col + 1)
        val left = nums(row)(col - 1)

        val n = nums(row)(col)
        if (n < above && n < below && n < right && n < left) {
          risks += n + 1
        }
      }
    }

    println(s"Part one: ${risks.sum}")
  }

  def partTwo(): Unit = {
    // Part one, basically
    var lowPointPositions = ArrayBuffer[(Int, Int)]()
    for (row <- 1 to nums.length - 2) {
      for (col <- 1 to nums(0).length - 2) {
        val above = nums(row - 1)(col)
        val below = nums(row + 1)(col)
        val right = nums(row)(col + 1)
        val left = nums(row)(col - 1)

        val n = nums(row)(col)
        if (n < above && n < below && n < right && n < left) {
          lowPointPositions += ((row, col))
        }
      }
    }

    var basinRisks = ArrayBuffer[Int]()
    var positions = ArrayBuffer[(Int, Int)]()
    def traverse(
        acc: Int,
        row: Int,
        col: Int
    ): Int = {
      val n = nums(row)(col)

      if (positions.contains((row, col))) {
        return acc
      } else if (n >= 9) {
        positions += ((row, col))
        return acc
      } else {
        val ret = acc + 1
        positions += ((row, col))

        val sum1 = traverse(0, row - 1, col)
        val sum2 = traverse(0, row + 1, col)
        val sum3 = traverse(0, row, col - 1)
        val sum4 = traverse(0, row, col + 1)
        return ret + sum1 + sum2 + sum3 + sum4
      }
    }

    // Looked around for some hints and realized you can just go by the low point positions from part one.
    lowPointPositions.foreach({ case (row, col) =>
      val acc = traverse(0, row, col)
      positions.clear()

      basinRisks += acc
    })

    println(
      s"Part two: ${basinRisks.sorted.reverse.view(0, 3).foldLeft(1)(_ * _)}"
    )
  }

  partOne()
  partTwo()
}
