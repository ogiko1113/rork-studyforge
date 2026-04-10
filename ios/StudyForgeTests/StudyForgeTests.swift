//
//  StudyForgeTests.swift
//  StudyForgeTests
//
//  Created by Rork on April 10, 2026.
//

import Testing
@testable import StudyForge

struct StudyForgeTests {

    // MARK: - SM2

    @Test func sm2NewCardGrade5() {
        let card = Card(front: "q", back: "a", deck: "d")
        let result = SM2.calculate(card: card, grade: 5)
        #expect(result.interval == 1)
        #expect(result.repetitions == 1)
    }

    @Test func sm2SecondGoodReview() {
        let card = Card(front: "q", back: "a", deck: "d", repetitions: 1)
        let result = SM2.calculate(card: card, grade: 4)
        #expect(result.interval == 6)
        #expect(result.repetitions == 2)
    }

    @Test func sm2FailureResetsRepetitions() {
        let card = Card(front: "q", back: "a", deck: "d", interval: 20, repetitions: 3)
        let result = SM2.calculate(card: card, grade: 1)
        #expect(result.repetitions == 0)
        #expect(result.interval == 1)
    }

    @Test func sm2EFClampedAt1_3() {
        var card = Card(front: "q", back: "a", deck: "d")
        for _ in 0..<20 {
            let result = SM2.calculate(card: card, grade: 1)
            card.ef = result.ef
            card.interval = result.interval
            card.repetitions = result.repetitions
            card.nextReview = result.nextReview
        }
        #expect(card.ef >= 1.3)
    }

    // MARK: - ImportParser

    @Test func parseTabSeparated() {
        let result = ImportParser.parse("foo\tbar")
        #expect(result.count == 1)
        #expect(result.first?.front == "foo")
        #expect(result.first?.back == "bar")
    }

    @Test func parseCSV() {
        let result = ImportParser.parse("foo,bar")
        #expect(result.count == 1)
        #expect(result.first?.front == "foo")
        #expect(result.first?.back == "bar")
    }

    @Test func parseSkipsBlankLines() {
        let result = ImportParser.parse("\nfoo\tbar\n\n")
        #expect(result.count == 1)
        #expect(result.first?.front == "foo")
        #expect(result.first?.back == "bar")
    }

    @Test func parseSkipsWhenEitherSideEmpty() {
        let result = ImportParser.parse("foo,\n,bar")
        #expect(result.isEmpty)
    }

}
