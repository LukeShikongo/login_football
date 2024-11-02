/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(); // Initializes the Firebase Admin SDK

// Firestore reference to the team and fixture collections
const db = admin.firestore();
const fixturesRef = db.collection('fixtures');
const teamsRef = db.collection('Team');

// Trigger when any document in the "fixtures" collection is updated
exports.onFixtureUpdate = functions.firestore.document('fixtures/{fixtureId}')
    .onUpdate(async (change, context) => {
        const newFixtureData = change.after.data();  // Get the updated fixture data
        const fixtureId = context.params.fixtureId;  // Get the fixture ID

        const homeTeamId = newFixtureData.homeTeamId;
        const awayTeamId = newFixtureData.awayTeamId;

        const homeScore = newFixtureData.homeScore;
        const awayScore = newFixtureData.awayScore;

        // Update team statistics based on the fixture results
        await updateTeamStats(homeTeamId, awayTeamId, homeScore, awayScore);
        console.log(`Updated team stats for fixture: ${fixtureId}`);
    });

async function updateTeamStats(homeTeamId, awayTeamId, homeScore, awayScore) {
    try {
        const homeTeamDoc = await teamsRef.doc(homeTeamId).get();
        const awayTeamDoc = await teamsRef.doc(awayTeamId).get();

        if (!homeTeamDoc.exists || !awayTeamDoc.exists) {
            console.error('One or both teams do not exist.');
            return;
        }

        const homeTeamData = homeTeamDoc.data();
        const awayTeamData = awayTeamDoc.data();

        // Determine the outcome of the match
        let homeTeamWon = homeScore > awayScore;
        let awayTeamWon = awayScore > homeScore;
        let isDraw = homeScore === awayScore;

        // Update home team stats
        let homeTeamUpdates = calculateUpdatedStats(homeTeamData, homeTeamWon, !homeTeamWon && !isDraw, isDraw, homeScore, awayScore);
        // Update away team stats
        let awayTeamUpdates = calculateUpdatedStats(awayTeamData, awayTeamWon, !awayTeamWon && !isDraw, isDraw, awayScore, homeScore);

        // Commit the updates to the Firestore
        await teamsRef.doc(homeTeamId).update(homeTeamUpdates);
        await teamsRef.doc(awayTeamId).update(awayTeamUpdates);

        console.log(`Team stats updated for teams: ${homeTeamId}, ${awayTeamId}`);
    } catch (error) {
        console.error('Error updating team stats: ', error);
    }
}

function calculateUpdatedStats(teamData, won, lost, drawn, goalsFor, goalsAgainst) {
    // Calculate updated team statistics
    let matchesPlayed = teamData['Match played'] || 0;
    let matchesWon = teamData['Match won'] || 0;
    let matchesLost = teamData['Match lost'] || 0;
    let matchesDrawn = teamData['Match drawn'] || 0;
    let points = teamData['Points'] || 0;
    let goalDifference = teamData['Goal difference'] || 0;

    matchesPlayed += 1;

    if (won) {
        matchesWon += 1;
        points += 3;
    } else if (lost) {
        matchesLost += 1;
    } else if (drawn) {
        matchesDrawn += 1;
        points += 1;
    }

    goalDifference += (goalsFor - goalsAgainst);

    // Return the updated data
    return {
        'Match played': matchesPlayed,
        'Match won': matchesWon,
        'Match lost': matchesLost,
        'Match drawn': matchesDrawn,
        'Points': points,
        'Goal difference': goalDifference,
    };
}
