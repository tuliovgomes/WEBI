const mario = document.querySelector('.mario');
const pipe = document.querySelector('.pipe');
const gameOver = document.querySelector('.game-over');
const score = document.querySelector('.score');
const highScore = document.querySelector('#high-score');

const setCookie = function (name, value, expirationDays) {
    const date = new Date();
    date.setTime(date.getTime() + (expirationDays * 24 * 60 * 60 * 1000));
    let expires = "expires=" + date.toUTCString();

    document.cookie = name + "=" + value + ";" + expires + ";SameSite=Lax;path=/";
};

const getCookie = function (name) {
    let decodedCookie = decodeURIComponent(document.cookie);
    let ca = decodedCookie.split(';');
    name = name + "=";

    console.log(ca);
    for (let i = 0; i < ca.length; i++) {
        let c = ca[i];

        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }

        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }

    return "";
};

var scoreValue = -1;
var highScoreValue = getCookie('high-score');

highScore.textContent = getCookie('high-score');

const jump = () => {
    if (
        gameOver.style.display === 'block'
        || mario.classList.contains('jump')
    ) {
        return;
    }

    mario.classList.add('jump');

    scoreValue += 1;
    score.textContent = scoreValue;

    if (highScoreValue < scoreValue) {
        setCookie('high-score', scoreValue, 365);
        highScoreValue = scoreValue;
        highScore.textContent = highScoreValue;
    }

    setTimeout(() => {
        mario.classList.remove('jump');
    }, 500);
}

const waitingFailure = () => {
    const pipePosition = pipe.offsetLeft;
    const marioPosition = +window.getComputedStyle(mario).bottom.replace('px', '');

    if (
        pipePosition <= 120
        && pipePosition > 0
        && marioPosition < 112
    ) {
        mario.style.animationPlayState = 'paused';
        mario.style.bottom = `${marioPosition}px`;

        pipe.style.animation = 'none';
        pipe.style.left = `${pipePosition}px`;

        mario.src = './images/game-over.png';
        mario.style.width = '75px';
        mario.style.marginLeft = '50px';

        gameOver.style.display = 'block';

        clearInterval(loop);

        document.removeEventListener('keydown', jump);
        document.removeEventListener('touchstart', jump);
    }
};

var loop = setInterval(waitingFailure, 10);

const restartGame = function () {
    gameOver.style.display = 'none';

    mario.style.animationPlayState = 'running';
    mario.src = './images/mario.gif';
    mario.style.width = '150px';
    mario.style.marginLeft = '0';
    mario.style.bottom = '0';

    pipe.style.left = 'auto';
    pipe.style.animation = 'pipe-animation 1s infinite linear';

    scoreValue = 0;
    score.textContent = scoreValue;

    document.addEventListener('keydown', jump);
    document.addEventListener('touchstart', jump);

    loop = setInterval(waitingFailure, 10);
};

document.querySelector('.retry').addEventListener('click', restartGame);

document.querySelector('.game-board').addEventListener('keydown', jump);
document.querySelector('.game-board').addEventListener('touchstart', jump);