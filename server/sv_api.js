const youtubedl = require('youtube-dl-exec')
const logger = require('progress-estimator')()

const cachedYT = {}

const loadYT = async (id) => {
    if (cachedYT[id]) return cachedYT[id];

    const videoURL = `https://www.youtube.com/watch?v=${id}`;
    const promise = youtubedl(videoURL, {
        dumpSingleJson: true,
        noCheckCertificates: true,
        // noWarnings: true,
        preferFreeFormats: true,
        addHeader: [
            'referer:youtube.com',
            'user-agent:googlebot'
        ]

    })

    // promise.then((result) => {
    //     console.log(result)
    // }).catch((err) => {
    //     console.log(err)
    // })
    
    const result = await logger(promise, `Obtaining ${id}`)

    const title = result.title
    const duration = result.duration
    const audioFormat = result.requested_formats.find((x) => x.resolution == "audio only")
    const audioURL = audioFormat.url

    return cachedYT[id] = {
        title: title,
        duration: duration,
        url: audioURL,
    }
}

// onNet('bs-vehicleradio:api:loadYT', async (id) => {
//     const src = source;
//     const yt = await loadYT(id)
//     emitNet('bs-vehicleradio:api:client:loadYT', src, yt)
// })

globalThis.exports('loadYT', async (id) => {
    const yt = await loadYT(id)
    return yt
})